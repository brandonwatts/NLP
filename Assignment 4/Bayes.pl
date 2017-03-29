


use feature qw(say switch);
use warnings;

use File::Slurp;
use XML::Simple;
use Data::Dumper;

##### Will hold our unigram of all words ###
my %frequencyTable;

my %features;

##### Will hold our data from the training file ###
my $data;

##### Frequency count of all the word types ###
my %wordTypes;

##### Final hash of our guessed senses ###
my %guessedSenses;

##### Hash to hold all the words surrounding a given sense ###
my %wordsSurrounding;

my %featureToWordMap;

##### Traing data XML file ###
my $trainingData = read_file($ARGV[0]);

##### Test data XML file ###
my $testData = read_file($ARGV[1]);

main($trainingData, $testData);




#  Main method that kicks off execution of the program 
#
#  @param $_[1]  Will hold the training data xml
#  @param $_[2]  Will hold the test data xml
sub main {

    my $train = $_[0];
    my $test = $_[1];

    ### Format training data to proper XML ###
    $train =~ s/<@>//g;
    $train =~ s/<p>//g;
    $train =~ s/<\/p>//g;
    $train =~ s/&//g;

    ### Format test data to proper XML ###
    $test =~ s/<@>//g;
    $test =~ s/<p>//g;
    $test =~ s/<\/p>//g;
    $test =~ s/&//g;

   # create XML object
    my $xml = new XML::Simple;

    # parse training data xml
    $data = $xml->XMLin($train);

    # parse test data xml
    $testData = $xml->XMLin($test);

    print(Dumper($data));
    createWordsSurrounding("phone");
    createWordsSurrounding("product");
    print(STDERR $frequencyTable{"a"});
    computeSenseID();
    #createAnswerFile();
}


#  Method that creates a hash of all the words surrounding a particular hash 
#
#  @param $_[0]  The senseID
sub createWordsSurrounding {
       
    my $senseid = $_[0];
    print STDERR "Creating Words surrounding $senseid...\n";
    my @surroundingWords = ();
    my $allWords = ();

    ##### For each instance #####
    for $instance ( keys %$data->{lexelt}->{instance} ) {

        ##### If the senseID for this instance equals our senseID #####
        if ($data->{lexelt}->{instance}->{$instance}->{answer}->{senseid} eq $senseid){
           
           ##### Per the xml parser 's' can either be an array or a hash #####
           if (ref($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){
           
                 ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                foreach my $surroundingWords ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                    push(@surroundingWords,$surroundingWords);
                }
            }

            ##### Array #####    
            else {

                ##### Break array up in to individual parts #####    
                foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {

                    ##### For each part of the array #####    
                    foreach my $p (@$part){

                        ##### The array may contain a hash #####    
                        if(ref($p) eq "HASH"){

                            ##### Grab the content #####    
                            foreach my $surroundingWords ($p->{content}){

                                ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                                foreach my $s (@$surroundingWords){
                                    push(@surroundingWords,$s);
                                }
                            }
                        }

                        ##### Array #####
                        else {
                            push(@surroundingWords,$p);
                        }
                    }
                }
            }
        }
    }

    ##### Combine all the surrounding sentences into one giant string #####
    my $allWords = join(' ',@surroundingWords);

    ##### Delete all of the Tabs and remove extra Spaces. #####
    $allWords =~ s/\s+|_/ /g; 

    my @individualWords = $allWords =~ /\S+/g;

         foreach my $word (@individualWords) {
          $frequencyTable{$word}++;
        }

    ##### Place the senseID in the hash mappepd to the words that surround it #####
    $wordsSurrounding{$senseid} = $allWords;


    print STDERR "Done!\n";
}


#  Method that computes a sense for a particualar instance 
sub computeSenseID {
    
    ##### Store max so we can determine argmax #####    
    my $max;

    ##### Temp var used to store all of the strings #####
    my $allWords = ();

    ##### Strings broken down into individual words #####
    my @words =();

    ##### Strings surroundign a given word #####
    my @surroundingWords = ();

    ##### Types the word 'line' could have #####
    my @types = ("phone","product");

    ##### Sense we ar guessing #####
    my $guessedSense = "UNDETERMINED";

        ##### For each instance #####
    for $instance ( keys %$testData->{lexelt}->{instance} ) {
           
           ##### Per the xml parser 's' can either be an array or a hash #####
           if (ref($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){
           
                 ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                foreach my $s (@$testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                    push(@surroundingWords,$s);

                }
                print STDERR "jgsfjgh;dfshglhfdglnsfljkghfndsh @surroundingWords[0]";

            }

            ##### Array #####    
            else {

                ##### Break array up in to individual parts #####    
                foreach my $part ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {

                    ##### For each part of the array #####    
                    foreach my $p (@$part){

                        print STDERR "THIS IS P: $p";

                        ##### The array may contain a hash #####    
                        if(ref($p) eq "HASH"){

                            ##### Grab the content #####    
                            foreach my $surroundingWords ($p->{content}){

                                ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                                foreach my $s (@$surroundingWords){
                                    push(@surroundingWords,$s);

                                }
                            }
                        }
                    }
                }
            }
    }
}







#  Helper method to get the number of times a particular word occured with a feature 
#
#  @param $_[0]  Word
#  @param $_[1]  Feature
#  @return       Number of times word occured with the feature
sub getTimesWordOccuredWithFeature {
    my $searchWord = $_[0];
    my $senseid = $_[1];

    ##### Get all the words that surround the feature #####
    $wordsSurroundingFeature = $wordsSurrounding{$senseid};

    ##### Delete all of the Tabs and remove extra Spaces. #####
    $wordsSurroundingFeature =~ s/\s+|_/ /g; 

    ##### Break that string into individual words #####
    my @individualWords = $wordsSurroundingFeature=~ /\S+/g;

    ##### Keep a count of how many times we see the word #####
    my $counter = 0;

    foreach my $word (@individualWords) {
        if($word eq $searchWord){
            $counter++;
        } 
    }

    return $counter;
}