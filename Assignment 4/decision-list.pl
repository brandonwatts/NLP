#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 4 - decision-list.pl
# 3/27/17

######## SUMMARY #########

# This program attempts to perform sentence disambiguation using Naive Bayes. 
# We use the bag-of-word (unigram) model to provide context
# to a given word. From there we decide what is the correct meaning of the word. 

######## ACCURACY ########

# Naive Bayes is a very powerful algorithim so I was capable of achieving a 100% accuracy.

########## EXAMPLE USE CASE #########

# $ perl decision-list.pl line-train.txt line-test.txt > my-line-answers.txt
#
# The first arguement is the file in which our training data is stored and the second file is the test data. The last arguement is the file which
# you want the output (Tagged answers) written to.

######### ALGORITHIMS ########

# Algorithims are decribed in detail below but the idea is that the file line-train.txt is parsed with an XML Parser to obtain the information stored within it From there
# we create our freatures by iterating through line-train.txt and createing a unigram model for our training data. We then take a count of all the 
# different word types for each instance. After that we gather all the words surrounding each instance (bag-of-words). From there we conpute our 
# guessed senses and write them to an output file.
#
#   1) Format both the training data and the test data so we can pass it in to our XML Parser.
#   2) Pass both training data and test data into an XML Parser.
#   3) Iterate through through all the words in the training data and create a unigram model.
#   4) Iterate through through all the instances in the training data and create a frequency count for each SenseID.
#   5) We then create a hash of all the words surrounding each instace for easy retrieval
#   6) From there we iterate through every instance and grab all the words surrouding our unknown word. And then for every type and every word we compute
#      Probablity if the sense + log(Times Word Occured With Feature/ times Word Appeared in Training Data)
#   7) Argmax of that calculation is our guessed sense
#   8) Finally we combine the instance id and the guessed sense to build our answer file

########## REFERENCES #########

# "6 Easy Steps to Learn Naive Bayes" - https://www.analyticsvidhya.com/blog/2015/09/naive-bayes-explained/
# "File::Slurp" - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm
# "XML::Simple" - http://search.cpan.org/~grantm/XML-Simple-2.22/lib/XML/Simple.pm

use feature qw(say switch);
use warnings;

use File::Slurp;
use XML::Simple;

##### Will hold our unigram of all words ###
my %frequencyTable;

##### Will hold our data from the training file ###
my $data;

##### Frequency count of all the word types ###
my %wordTypes;

##### Final hash of our guessed senses ###
my %guessedSenses;

##### Hash to hold all the words surrounding a given sense ###
my %wordsSurrounding;

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

    createFeatures();
    createWordTypes();
    createWordsSurrounding("phone");
    createWordsSurrounding("product");
    computeSenseID();
    createAnswerFile();
}

#  Method that creates features using bag-of-words
sub createFeatures {
    print STDERR "Creating Features...\n";

    ##### Words surrounding our ambigious word #####
    my @surroundingWords = ();

    my @allWords = ();

    ##### For each instance #####
    for $instance ( keys %$data->{lexelt}->{instance} ) {

        ##### For each sentance ('s') #####
        foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
            
        ##### Per the xml parser 's' can either be an array or a hash #####
            foreach my $p ($part) {

                ##### If it is a hash it stores more words and the ambigous word itself#####
                if(ref($p) eq "HASH"){

                    ##### Grab the content (which is an array) #####
                    foreach my $surroundingWords ($p->{content}){

                        ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                        foreach my $s (@$surroundingWords){
                            push(@surroundingWords,$s);
                        }
                    }
                }

                ##### If it is an array it just stores the surroundign word so just push it to a temp array #####
                else{
                    push(@surroundingWords,$p);
                }
            }    
        }       
    }

    ##### Combine all the surrounding sentences into one giant string #####
    my $allWords = join(' ',@surroundingWords);

    ##### Delete all of the Tabs and remove extra Spaces. #####
    $allWords =~ s/\s+|_/ /g; 

    ##### Break the string up in to individual words. #####
    my @words = $allWords=~ /\S+/g;

    ##### Iterate through all the words and count how many times it appears in the file #####
    foreach my $word (@words) { $frequencyTable{$word}++;}

    print STDERR "Done!\n";
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

    ##### Place the senseID in the hash mappepd to the words that surround it #####
    $wordsSurrounding{$senseid} = $allWords;

    print STDERR "Done!\n";
}


#  Method counts the number of times a particular sense occurs 
sub createWordTypes {
    print STDERR "Creating Word Types...\n";

    ##### For each instance #####
    for $instance ( keys %$data->{lexelt}->{instance} ) {

        ##### Grab the senseID #####
        my $senseid = $data->{lexelt}->{instance}->{$instance}->{answer}->{senseid};

        ##### Count the number of times that sense is seen and place into a hash #####
        $wordTypes{$senseid}++;
    } 

    print STDERR "Done!\n";
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

    ########## For Every instance ##########
    for $instance ( keys%$testData->{lexelt}->{instance}) {
        print STDERR "Computing senseid for instance: ". $instance ."\n";
        
        ########## Empty variables from the previous instance  ##########
        $allWords = ();
        @words =();
        @surroundingWords = ();

        ########## The 2 senses the word "line" can have is "product" and "phone" ##########
        @types = ("product","phone");

        ########## Set the default sense to undetermined for easier debugging if a sense is not chosen ##########
        $guessedSense = "UNDETERMINED";

        ##### Per the xml parser 's' can either be an array or a hash #####
        if (ref($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){

           ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
           foreach my $surroundingWords ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                    push(@surroundingWords,$surroundingWords);
                }
        }

        ########## 's' was an array ########## 
        else {

            ##### Break array up in to individual parts #####    
            foreach my $part ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {

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
                    else{
                        push(@surroundingWords,$p);
                    }
                }    
            }
        }

        ##### Place all the sentences into a giant string #####
        $allWords = join(' ',@surroundingWords);

        ##### Delete all of the Tabs and remove extra Spaces. #####
        $allWords =~ s/\s+|_/ /g; 

        ##### Break the sentences up into individual words #####
        @words = $allWords=~ /\S+/g;

        ##### Initialize max to be zero #####
        my $max = 0;

        ##### Used to store our sense guess #####
        my $typeScore;

        ##### For each type #####
        foreach my $type (@types){


            ##### Iterate through all the words that surround that instance #####
            foreach my $word (@words) {
                

                    if(getTimesWordOccuredWithFeature($word,$type) == 0)
                    {
                        $typeScore = 0;
                    }
                    else 
                    {
                        $typeScore = log(getTimesWordOccuredWithFeature($word,$type)/$frequencyTable{$word});

                    }

                
    



                foreach my $feature (@words) {

                    ##### Count how many times that word appeared within our training data  #####
                    my $timesWordAppearedinTrainingData = $frequencyTable{$word};

                    ##### Count how many times that wprd appeared with that feature #####
                    my $TimesWordOccuredWithFeature = getTimesWordOccuredWithFeature($word,$type);

                    my $timesTypeOcuured = $wordTypes{$type};

                    ##### If that word did not occour with our feature then just move on  #####
                    if($TimesWordOccuredWithFeature == 0){ next; }

                    ##### Perform calculation  #####
                    $typeScore += log($TimesWordOccuredWithFeature/$timesTypeOcuured);
                }
            } 

            ##### If the score is greater than our max then this is the senseID we choose #####
            if (abs($typeScore) > $max) {
                $max = abs($typeScore);
                $guessedSense = $type;
            }
        }

        ##### Place our guess in a hash #####
        $guessedSenses{$instance} = $guessedSense;
        
        print STDERR "Done!\n";
    }
}


#  Method that generates the tagged output file 
sub createAnswerFile {
    print STDERR "Creating the answer file...\n";

    ##### Add start tag #####
    printf(STDOUT "<answers>\n");

    ##### Iterate through all of our guesses and output then to a file with the correct formating #####
    foreach $guess (keys %guessedSenses) {    # Loop through the dictionary
        printf(STDOUT "<answer instance=\"$guess\" senseid=\"$guessedSenses{$guess}\"/>\n");
    }

    ##### Add end tag #####
    printf(STDOUT "<\/answers>\n");

    print STDERR "Done!\n"
}