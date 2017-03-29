#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 4 - decision-list.pl
# 3/27/17

######## SUMMARY #########

# This is a helper program to score the output of decision-list.pl against the key data. 

########## EXAMPLE USE CASE #########

# $ perl scorer.pl my-line-answers.txt line-key.txt
#
# The first arguement is the file is the file output from decision-list.pl while the second file is key data.

######### ALGORITHIMS ########

# There we really no algorithims used here, but the steps below were taken:
#   
#   1) parse the key file with an XML Parser.
#   2) Parse the answer file with an XML parser.
#   3) Compare the senseID of the answer to the senseID of the key.
#   4) Count how many we got right and wrong to produce accuracy.
#   5) Also produce a confusion matrix

########## REFERENCES #########

# "File::Slurp" - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm
# "XML::Simple" - http://search.cpan.org/~grantm/XML-Simple-2.22/lib/XML/Simple.pm

use File::Slurp;
use warnings;
use feature qw(say switch);
use XML::Simple;

### Training data file ###
my $answers = read_file($ARGV[0]);

### Test data file ###
my $key = $ARGV[1];

### Confusion Matrix ###
my %confusionMatrix;

### Answer Matrix ###
my $answerHash;

### Key Matrix ###
my $keyHash;

processKey($key);
processAnswers($answers);
computeAccuracy();

#  Function to process our key file by putting it in XML format, and passing it to an XML parser to extract data
#
#  @param $_[0]  Will hold the key file 
sub processKey{
    my $key = $_[0];

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
    foreach my $instances ($keyHash->{answer}){
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
        
        ##### Grab the senseID #####
        foreach my $id (@$instances){

            ##### If the senseID of the key is equal to my guessed senseID #####
            if(($id->{senseid}) eq ($keyMapping{$id->{instance}})) {
                $confusionMatrix{$id->{senseid}}{$keyMapping{$id->{instance}}}++;
                $true++;
                $total++;
            } 

            ##### The senseID of they key is not equal to my guessed senseID. #####
            else {
                $confusionMatrix{$id->{senseid}}{$keyMapping{$id->{instance}}}++;
                $false++;
                $total++;
            }
        }
    }

    ######################################## OUTPUT DATA ########################################
    say "---------------------------- Confusion Matrix ----------------------------\n";

    for my $key ( keys %confusionMatrix ) {
        
        print(STDOUT "###################### $key ######################\n");

        for my $value ( keys %{ $confusionMatrix{$key} } ) {
            printf(STDOUT "Chose: %-7s | Correct: %-7s | Number: %-5s", $key, $value,$confusionMatrix{$key}{$value}); printf (STDOUT "| Percentage of file: %.2f", ($confusionMatrix{$key}{$value}/$total)*100);print("\%\n");
        }
        print STDOUT "\n";
    }

    say "Total Correct: $true";
    say "Total Incorrect: $false";
    $PercentageCorrect = $true/$total;
    $PercentageIncorrect = $false/$total;

    printf (STDOUT "Percentage Correct: %.2f", ($PercentageCorrect)*100);print("\%\n");
    printf (STDOUT "Percentage Incorrect: %.2f", ($PercentageIncorrect)*100);print("\%\n");
    ################################################################################################
}