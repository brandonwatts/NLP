#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 4 - decision-list.pl
# 3/27/17

######## SUMMARY #########

# This program attempts to perform sentence disambiguation using a decision list classifier. It uses the training data to build features
# and then with those features, it builds tests. We then use the order of the tests to figure out the sense.

######## ACCURACY ########

# I was able to achieve a 88.1% accuracy. I think i could have gotten it a little higher with a better parsing strategy.

########## EXAMPLE USE CASE #########

# $ perl decision-list.pl line-train.txt line-test.txt > my-line-answers.txt
#
# The first arguement is the file in which our training data is stored and the second file is the test data. The last arguement is the file which
# you want the output (Tagged answers) written to.

######### ALGORITHIMS ########

# Algorithims are decribed in detail below but the idea is that the file line-train.txt is parsed with an XML Parser to obtain the information stored within it From there
# we create our freatures by iterating through line-train.txt and createing a unigram model for our training data. From the features we
# build tests that if pass will give us a sense. We order these tests in the highest rank. To process the test file, we create feature 
# vectors for each instance. We pass these feature vectors through our now ordered tests to produce a sense. That sense is then used to generate our
# output file.
#
#   1) Format both the training data and the test data so we can pass it in to our XML Parser.
#   2) Pass both training data and test data into an XML Parser.
#   3) Iterate through through all the words in the training data and create a unigram model of features.
#   4) We then create a hash of all the words surrounding each instace for easy retrieval
#   5) From there we create and order our tests based on thier rank
#   6) We create feature vectors for every instance in the test data
#   7) We pass each feature vector through our list of tests to compute a sense id
#   8) Finally we use that sense id to produce an output file in XML

########## REFERENCES #########

# "File::Slurp" - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm
# "XML::Simple" - http://search.cpan.org/~grantm/XML-Simple-2.22/lib/XML/Simple.pm

use feature qw(say switch);
use warnings;

use File::Slurp;
use XML::Simple;

##### Hash from features to thier count within the test file #####
my %features;

##### Hash from a feature to its ranking #####
my %rankedFeatures;

##### Tests in the order they will be applied  #####
my @orderedFeatures;

##### Will hold our data from the training file ###
my $data;

##### Frequency count of all the word types ###
my %wordTypes;

##### Final hash of our guessed senses ###
my %guessedSenses;

##### Hash to hold all the words surrounding a given sense #####
my %wordsSurrounding;

##### Hash from an instance to its repective feature vector #####
my %instanceToFeatureVector;

##### Traing data XML file ###
my $trainingData = read_file($ARGV[0]);

##### Test data XML file ###
my $testData = read_file($ARGV[1]);

my $output = $ARGV[2];

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

    ##### Create features from unigram model of each instance #####
    createFeatures();

    ##### Order those features by decreasing frequency #####
    orderFeatures();

    ##### Create a hash of all the words that surround phone for easy retrieval later #####
    createWordsSurrounding("phone");

    ##### Create a hash of all the words that surround product for easy retrieval later #####
    createWordsSurrounding("product");

    ##### Rank tests based off of evaluation of each feature #####
    rankTests();

    ##### Create a Feature vectors for each instance in our test file #####
    createFeatureVector(); 

    ##### Compute the sense id for each instance in our test file #####   
    computeSenseID();

    ##### Create an answer file output in XML #####
    createAnswerFile();

    outputFeatures();
}

#  Method that creates features using unigram model
sub createFeatures {

    print STDERR "Creating Features...\n";

    ##### Words surrounding our ambigious word #####
    my @surroundingWords = ();

    ##### For each instance #####
    for $instance ( keys %$data->{lexelt}->{instance} ) {

        ##### For each sentence ('s') #####
        foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
            
            ##### Per the xml parser 's' can either be an array or a hash #####
            foreach my $p ($part) {
                
                if(ref($p) eq "ARRAY"){

                    foreach my $section (@$p) {

                        ##### If it is a hash it stores more words and the ambigous word itself#####
                        if(ref($section) eq "HASH"){

                            ##### Grab the content (which is an array) #####
                            foreach my $surroundingWords ($section->{content}){

                                ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                                foreach my $s (@$surroundingWords){
                                    $s =~ s/[\.?!\)\("-]//g; 
                                    $s =~ s/\d+/num/g;
                                    push(@surroundingWords,$s);
                                }
                            }

                            ##### If there are surounding words add them to our features #####
                            if (exists $surroundingWords[0]) {
                                my @wordsBefore =  $surroundingWords[0] =~ /\S+/g;
                                my $wordBeforeSize = @wordsBefore;

                                for my $word (@wordsBefore) {
                                        $features{$word}++;
                                } 
                            }

                            ##### If there are surounding words add them to our features #####
                            if (exists $surroundingWords[1]) {
              
                                my @wordsAfter =  $surroundingWords[1] =~ /\S+/g;
                    
                                for my $word (@wordsAfter) {
                                    $features{$word}++;
                                } 
                            }

                            @surroundingWords = ();
                        }
                    }
                }

                ##### It is a hash #####
                else{

                    ##### Get the content #####
                    foreach my $surroundingWords ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){

                        ##### Iterate through the content and grab all the surrounding sentences and push them to temp array #####
                        foreach my $s (@$surroundingWords){
                            $s =~ s/[\.?!\)\("-]//g; 
                            $s =~ s/\d+/num/g;
                            push(@surroundingWords,$s);
                        }
                    }

                    ##### If there are surounding words add them to our features #####
                    if (exists $surroundingWords[0]) {
                        my @wordsBefore =  $surroundingWords[0] =~ /\S+/g;
                         for my $word (@wordsBefore) {
                            $features{$word}++;
                        } 
                    }

                    ##### If there are surounding words add them to our features #####
                    if (exists $surroundingWords[1]) {
                        my @wordsAfter =  $surroundingWords[1] =~ /\S+/g;
                          for my $word (@wordsAfter) {
                            $features{$word}++;
                        } 
                    }

                    @surroundingWords = ();
                }
            }     
        }       
    }
    print STDERR "Done!\n";
}


#  Method that creates feature vectors for each instance in the test file
sub createFeatureVector(){

    print STDERR "Creating Feature Vectors...\n";

    ##### GRAB ALL THE SURROUNDING WORDS BOILERPLATE CODE ##########
    for $instance ( keys %$testData->{lexelt}->{instance} ) {

        @surroundingWords = ();
        my $allWords = ();

        foreach my $part ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {

            if(ref($part) eq "HASH"){

                foreach my $sentence ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}) {
                    
                    foreach my $s (@$sentence)
                    {
                        push(@surroundingWords,$s);
                    }
                }
            } 

            else{
                foreach my $subpart ($part) {

                    foreach my $s (@$subpart){

                        if (ref($s) eq "HASH"){

                            foreach my $sentence ($s->{content}) {

                                foreach my $x (@$sentence) {

                                     push(@surroundingWords,$x);

                                }
                            }
                        }

                        else{
                        push(@surroundingWords,$s);
                        }
                    }
                }
            }
        }

        $allWords = join(' ',@surroundingWords);

        $allWords =~ s/\s+|_/ /g; 
        $allWords =~ s/[\.?!\)\("-]//g; 
        $allWords =~ s/\d+/num/g;

        my @words = $allWords=~ /\S+/g;

        ################################################################################


        my @featureVector;

        ##### For each feature #####
        foreach $feature (@orderedFeatures) {  

            ##### If our feature is present in the surrounding words #####
            if( $allWords =~ /$feature/) {

                ##### Push a 1 on to the array #####
                push @featureVector, 1;
            }

            ##### If our feature is not present in the surrounding words #####
            else{

                ##### Push a 1 on to the array #####
                push @featureVector, 0;
            }
        }

        ##### Map the instance to its respective feature vector #####
        $instanceToFeatureVector{$instance} = [@featureVector];
    }
    print STDERR "Done!\n";
}

#  Method that creates a hash of all the words surrounding a particular hash 
#
#  @param $_[0]  The senseID
sub createWordsSurrounding {
       
    my $senseid = $_[0];
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
    $allWords = join(' ',@surroundingWords);

    ##### Delete all of the Tabs and remove extra Spaces. #####
    $allWords =~ s/\s+|_/ /g; 

    ##### Place the senseID in the hash mappepd to the words that surround it #####
    $wordsSurrounding{$senseid} = $allWords;
}

#  Method counts the number of times a particular sense occurs 
sub createWordTypes {

    ##### For each instance #####
    for $instance ( keys %$data->{lexelt}->{instance} ) {

        ##### Grab the senseID #####
        my $senseid = $data->{lexelt}->{instance}->{$instance}->{answer}->{senseid};

        ##### Count the number of times that sense is seen and place into a hash #####
        $wordTypes{$senseid}++;
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

#  Method to compute the rank for each test 
sub rankTests{

    print STDERR "Ranking Tests...\n";

    ##### Loop over each feature #####
    foreach $feature (@orderedFeatures) {  

        ##### Get the number of times it appeared with phone and add one to both so we dont divide by zero. #####
        $countOfSenseGivenFeaturePhone = getTimesWordOccuredWithFeature($feature, "phone") + 1;
            
        ##### Get the number of times it appeared with product #####
        $countOfSenseGivenFeatureProduct = getTimesWordOccuredWithFeature($feature, "product") + 1;

        ##### Get the number of times the feature occurs with product and add one to both so we dont divide by zero.  #####
        $countofFeature = $features{$feature};

        ##### compute the rank #####
        $rank = abs(log(($countOfSenseGivenFeaturePhone/$countofFeature) / ($countOfSenseGivenFeatureProduct/$countofFeature)));

        ##### Store that rank so we can sort based off it later #####
        $rankedFeatures{$feature} = $rank;
    }

    ##### Empty the array from earlier so we can place tests back in the correct order #####
    @orderedFeatures = ();

    ##### Place tests back in the correct order #####
    foreach my $key ( sort { $rankedFeatures{$b} <=> $rankedFeatures{$a} } keys %rankedFeatures ) {    # Loop through the dictionary
        push(@orderedFeatures,$key);
    }

    print STDERR "Done!\n";
}

#####  Helper method to order the features by decreasing frequency #####
sub orderFeatures{

    print STDERR "Ordeing Features...\n";

    foreach my $key ( sort { $features{$b} <=> $features{$a} } keys %features ) {   
        push(@orderedFeatures,$key);
    }

    print STDERR "Done!\n";
}

#  Method that takes the test file and computes the best possible sense from our ordered features 
sub computeSenseID{

    print STDERR "Computing SenseIDs...\n";

   ##### For each instance #####
    foreach my $instance ( keys %$testData->{lexelt}->{instance} ) {

        ##### Get the vector associated with that instance #####
        $featureVectorInstance = $instanceToFeatureVector{$instance};

        ##### Loop ove the tests in order #####
        foreach my $i (0 .. $#orderedFeatures) {

            ##### If the test passes #####  
            if (@$featureVectorInstance[$i] eq 1) {

                ##### Get the number of times the word occurs with "phone" #####
                my $phoneCount = getTimesWordOccuredWithFeature($orderedFeatures[$i],"phone");

                ##### Get the number of times the word occurs with "product" #####
                my $productCount = getTimesWordOccuredWithFeature($orderedFeatures[$i],"product");

                ##### Figure out what sense is most probable #####
                if($phoneCount >  $productCount)
                {
                    $guessedSenses{$instance} = "phone";
                }
                elsif($phoneCount <  $productCount)
                {
                    $guessedSenses{$instance} = "product";
                }

                ##### We have our sense so just break out of loop #####
                last;
            }
        }
    }

    print STDERR "Done!\n";
}

#  Method that generates the tagged output file 
sub createAnswerFile {

    print STDERR "Creating Answer File...\n";

    ##### Add start tag #####
    printf(STDOUT "<answers>\n");

    ##### Iterate through all of our guesses and output then to a file with the correct formating #####
    foreach $guess (keys %guessedSenses) {    # Loop through the dictionary
        printf(STDOUT "<answer instance=\"$guess\" senseid=\"$guessedSenses{$guess}\"/>\n");
    }

    ##### Add end tag #####
    printf(STDOUT "<\/answers>\n");

    print STDERR "Done!\n";
}

sub outputFeatures{

    print STDERR "Creating Decision List...\n";

    my $file = $output;

    foreach my $key ( sort { $rankedFeatures{$b} <=> $rankedFeatures{$a} } keys %rankedFeatures ) {    # Loop through the dictionary
        
        my $phoneCount = getTimesWordOccuredWithFeature($key,"phone");
        my $productCount = getTimesWordOccuredWithFeature($key,"product");
        
        if($phoneCount >  $productCount)
        {
            append_file( $file, "\nFEATURE: $key \t\t LOG-LIKEYHOOD: $rankedFeatures{$key} \t\t CHOOSEN SENSE: product\n") ;
            append_file($file,"----------------------------------------------------------------------------------------------------\n");
        }
        elsif($phoneCount <  $productCount)
        {
            append_file( $file, "\nFEATURE: $key \t\t LOG-LIKEYHOOD: $rankedFeatures{$key} \t\t CHOOSEN SENSE: phone\n");
            append_file($file,"----------------------------------------------------------------------------------------------------\n");

        }
    }
        print STDERR "Done!\n";
}