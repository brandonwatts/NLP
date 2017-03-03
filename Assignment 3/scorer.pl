#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 3 - Scorer
# 3/2/17

######## SUMMARY #########

# This program is a utility program to be used with tagger.pl. This program takes in two arguements: pos-test-with-tags.txt (This is 
# the file that is created by tagger.pl) & pos-test-key.txt (This file contains the correct POS tags for all the tokens and is considered
# the "gold standard".) We then specify an output file with the > charcter to insist on where the output file should be written to. The output file 
# contains the confusion matrix (This is a description of what tag was chosen, what was the correct tag, hwo many times was that choice made
# ,and the percentage that choice was made out of all of our choices). At the bottom of the output file is included 2 percentages: Correct & Incorrect,
# these percentages mark the amount of tags that were gussed correctly and the amount of words that were guessed incorrectly, respectively.

########## EXAMPLE USE CASE #########

# $ perl scorer.pl pos-test-with-tags.txt pos-test-key.txt > pos-tagging-report.txt
#
# The first arguement is the file of our guesses POS tags generated by the program tagger.pl. The second arguement is the "gold standard"
# key data. The third arguemnt is an output file where you would like the confusion matrix and accuracy printed.

######### ALGORITHIMS ########

# As this was a utility program for tagger.pl there are not many algorithims. Basically just file manipulation and comparison with the key
# but I will decribe below the process I used.
#
# 1) Start by reading in the tagged file and the key and place them in thier respective variables
# 2) We then start processing the key by striping it of al the brackets, and deleting unneded whitespace
# 3) From there we split the file into its individual token/tag combonation and then use a regex to place the tags in thier own aray
#    called "POSForKey"
# 4) We perform the exact same procedure on the tagged file
# 5) Our final process is looping through both arrays and checking if the pos tags are the same
# 6) If they are, we increment true variable and place it in our confusion matrix
# 7) If they are not, we increment the false variabe and place that in our confusion matrix as well
# 8) Lastly, we print the results to STDOUT.

########## REFERENCES #########

# "File::Slurp" - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm

use File::Slurp;

use warnings;
use feature qw(say switch);
use strict;

### Training data file ###
my $taggedFile = read_file($ARGV[0]);

### Test data file ###
my $key = read_file($ARGV[1]);

my %confusionMatrix;

my @POSForKey;

my @POSForTagged;

processKey($key);
processTagged($taggedFile);
computeAccuracy();

#  Method that process the key file and place all of its POS tags into an array.
#
#  @param $_[0]  Will hold the data stored within pos-test-key.txt   
sub processKey {
    my $keyData = $_[0];

    ### Delete the brackets ###
    $keyData =~ s/\[|\]/ /g;

    ### Delete all of the Tabs and remove extra spaces. ###
    $keyData =~ s/\s+|_/ /g;

    ### Extract all the sentece tokens into an array. ###
    my @sentenceTokens = $keyData=~ /\S+/g;  

    ### Loop through all the sentence tokens and pull out the POS tag using a regex and place it into an array. ###
    foreach my $i (0.. $#sentenceTokens ) {
       if ($sentenceTokens[$i] =~ /\S+\\?\/(\S+)/){ $POSForKey[$i] = $1;} 
    }
}

#  Method that process the tagged file and place all of its POS tags into an array.
#
#  @param $_[0]  Will hold the data stored within pos-test-with-tags.txt  
sub processTagged {
    my $taggedData = $_[0];

    ### Extract all the sentece tokens into an array. ###
    my @sentenceTokens = $taggedData=~ /\S+/g;
    
    ### Loop through all the sentence tokens and pull out the POS tag using a regex and place it into an array. ###
    foreach my $i (0.. $#sentenceTokens ) {
       if ($sentenceTokens[$i] =~ /\S+\\?\/(\S+)/){ $POSForTagged[$i] = $1;} 
    }
}

#  Method that will compute the accuacy, create a confusion matrix and output the data to the file specified.
sub computeAccuracy {

    ### Used to hold how many correct tags we guessed ###
    my $true = 0;

    ### Used to hold how many incorrect tags we guessed ###
    my $false = 0;

    ### Loop through the guessed POS tags and compare them to the "gold standard" ###
    foreach my $i (0.. $#POSForTagged ) {
        
        ### If the tags are equal we guessed right, so increment our true variable and place our findings in a confusion matrix ###
        if ($POSForTagged[$i] eq $POSForKey[$i]) { 
            $confusionMatrix{$POSForTagged[$i]}{$POSForKey[$i]}++;
            $true++; 
        }

        ### If the tags are not equal we guessed wrong, so increment our false variable and place our findings in a confusion matrix ### 
        else {
            $false++;
            $confusionMatrix{$POSForTagged[$i]}{$POSForKey[$i]}++;
        }
    }


    say "---------------------- Confusion Matrix ----------------------------";

    for my $key ( keys %confusionMatrix ) {
        
        print(STDOUT "########## $key ##########\n");

        for my $value ( keys %{ $confusionMatrix{$key} } ) {
            printf(STDOUT "Chose: %-7s | Correct: %-7s | Number: %-7s", $key, $value,$confusionMatrix{$key}{$value}); printf (STDOUT "| Percentage: %.4f\n", ($confusionMatrix{$key}{$value}/$#POSForTagged)*100);
        }
        print STDOUT "\n";
    }

    my $correctPercentage = $true/$#POSForTagged;
    my $incorrectPercentage = $false/$#POSForTagged;
    print (STDOUT "Percentage Correct: $correctPercentage\n");
    print (STDOUT "Percentage Incorrect: $incorrectPercentage\n");
}


