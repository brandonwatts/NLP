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

use File::Slurp;
use warnings;
use feature qw(say switch);
use XML::Simple;
use File::Slurp qw( prepend_file ) ;

### Training data file ###
my $answers = read_file($ARGV[0]);

### Test data file ###
my $key = $ARGV[1];

my %confusionMatrix;
my $answerHash;
my $keyHash;

processKey($key);
processAnswers($answers);
computeAccuracy();

#  Function to process our key file by putting it in XML format, and passing it to an XML parser to extract data
#
#  @param $_[0]  Will hold the key file 
sub processKey{
    my $key = $_[0];

    ##### We needto add start and end tags to conform to XML #####
    my $startTag = "<answers>\n";
    my $endTag = "<\/answers>\n";
    prepend_file( $key,  $startTag) ;
    append_file( $key, $endTag) ;

    ##### Now we can read the file in #####
    my $keyFile = read_file($key);

    ##### Extract data with an XML parser #####
    my $xml = new XML::Simple;
    $keyHash = $xml->XMLin($keyFile);
}

#  Function to process our answer file by passing it to an XML parser to extract data
#
#  @param $_[0]  Will hold the answer file 
sub processAnswers{
    my $answers = $_[0];
    my $xml = new XML::Simple;
    $answerHash = $xml->XMLin($answers);
}

#  Method that will compute the accuacy, create a confusion matrix and output the data to the file specified.
sub computeAccuracy {

    ##### Hashmap on a particular instance to my answer #####
    my %keyMapping;

    ##### Loop through all of the instances in the answer file and create the keyMapping #####
    foreach my $instances ($answerHash->{answer}){
            foreach my $id (@$instances){
               $keyMapping{$id->{instance}} = $id->{senseid};
            }
    }  

    
    ##### Loop through all of the instances in the answer file and create the keyMapping #####
    my $true = 0;

    ##### Loop through all of the instances in the answer file and create the keyMapping #####
    my $false = 0;

    ##### Loop through all of the instances in the answer file and create the keyMapping #####
    my $total = 0;

    ##### Loop through all of the instances in the answer file and create the keyMapping #####
    foreach my $instances ($answerHash->{answer}){
        foreach my $id (@$instances){
            if(($id->{senseid}) eq ($keyMapping{$id->{instance}})) {
                $true++;
                $total++;
            } 
            else {
                $false++;
                $total++;
            }
        }
    }

    say "Total Correct: $true";
    say "Total Incorrect: $false";
    $PercentageCorrect = $true/$total;
    $PercentageIncorrect = $false/$total;

    say "Percentage Correct: ".$PercentageCorrect*100;
    say "Percentage Incorrect: ".$PercentageIncorrect*100;
}