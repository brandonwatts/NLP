#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 3 - Tagger
# 3/2/17

######## SUMMARY #########

# This program attempts to perform POS (Part of Speech) tagging. It learns of of the training data set file pos-train.txt. From 
# there it will read in the file pos-test.txt and attempt to POS tag the tokens within that file. We then specify an output file 
# with the > charcter to insist on where the output file should be witten to. 


########## EXAMPLE USE CASE #########

# $ perl tagger.pl pos-train.txt pos-test.txt > pos-test-with-tags.txt
#
# The first arguement is the file in which our training data is stored and the second file is the test data. The las arguement is the file which
# you want the output written to.

######### ALGORITHIMS ########

# Algorithims are decribed in detail below but the idea is that the file pos-train.txt is split into its respective tokens. From there
# we are creating 3 different hashes : A hash called frequencyTable that holds the frequency of our POS tags, A double hash called wordToPOSMapping
# that hold a word to its POS tag mapped to the count, and a hash called POStoPOSMapping which holds a tag to its previous tag mapped to the count.
#
#   1) Process the training data by deleting all of the brackets, Deleting all the extra spaces, new line characters, and tabs
#      and replacing them with a single space.
#   2) We then create our Frequencytable, our WordToPOSMapping, and our training data, respectively.
#   3) From there we can begin to start generating our tagged file by looping through all the tokens in our test file,
#      running our getPOS() funtion on it, and then print it to the file pos-test-with-tags.txt
#   4) Our getPOS() function works by first checking if our word has been seen before.
#   5) If the word has been seen before, We compute the P(w,t) * P(t,t-1)  ** Probablity of the word given the tag times the
#      Probablity if the tag given the previous tag. ** The highest value is our POS guess.
#   6) If we have not seen the word before we attempt to apply some rules to figure out what the word is, but if all else fails, we will just call it a NNP (Proper Noun)

########## REFERENCES #########

# "Regular Expressions Cheat Sheet" - https://www.cheatography.com/davechild/cheat-sheets/regular-expressions/
# "Part-of-speech tagging" - https://en.wikipedia.org/wiki/Part-of-speech_tagging
# "File::Slurp" - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm

use warnings;
use feature qw(say switch);
use strict;

### CPAN Module which makes reading in the file easier and more intuitive ###
use File::Slurp;

### Holds the frequency count of all the POS tags ###
my %frequencyTable;

### Double hash of word to POS tag mapped to count ###
my %wordToPOSMapping;

### Double hash of POS tag to previous POS tag mapped to count ###
my %POStoPOSMapping;

### Training data file ###
my $trainingData = read_file($ARGV[0]);

### Test data file ###
my $testData = read_file($ARGV[1]);

preprocess($trainingData);
generateTaggedFile($testData);

#  Method that initializes the program 
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub preprocess {

    my $rawData = $_[0];

    ### Delete all of the brackets from the input file ###
    $rawData =~ s/\[|\]//g;

    ### Delete all of the Tabs and remove extra Spaces. ###
    $rawData =~ s/\s+|_/ /g;

    ### Trim the file ###
    $rawData =~ s/^\s+|\s+$//g; 

    createMappings($rawData);
}

#  Method that maps all the POS tags the the frequency in which they occur in the file
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createMappings{

    my $file = $_[0];

    ### Grab all the POS tags, semicolons, commas, and periods and place them in an array ###
    my @POS = $file=~ /\S+\\?\/(\S+)/g;
       
    ### Iterate over that array and count the number of times a tag has been seen ###
    for my $pos (@POS) { $frequencyTable{$pos}++; }

    foreach my $i (1.. $#POS ) { $POStoPOSMapping{$POS[$i]}{$POS[$i-1]}++; }

    createWordtoPOSMapping($file);
}

#  Method that maps all the words/tokens with thier respective POS tag
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createWordtoPOSMapping {
    my $data = $_[0];
    my @sentenceTokens = $data=~ /\S+\\?\/\S+/g;

    for my $token (@sentenceTokens) {

        ### Seperate the word from the POS into 2 capture groups ###
         if ($token =~ /(\S+)\\?\/(\S+)/) { $wordToPOSMapping{$1}{$2}++; }
    }
}

#  Method that generates the tagged output file 
#
#  @param $_[0]  Will hold the Trst data file in its entirety
sub generateTaggedFile {

    my $file = $_[0];

    $file =~ s/\[|\]/ /g;

    $file =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.


    my @sentenceTokens = $file=~ /\S+/g;

    foreach my $i (0.. $#sentenceTokens ) {
        
        my $POSGuess;

        if($i<1) { $POSGuess = getPOS($sentenceTokens[$i]);} 
            else { $POSGuess = getPOS($sentenceTokens[$i],$sentenceTokens[$i-1]);}
            print STDOUT "$sentenceTokens[$i]/$POSGuess\n";
    }
}

#  Method that get a POS tag given a word and its previous POS
#
#  @param $_[0]  The current word you are trying to find the POS tag of.
#  @param $_[1]  The previous word
sub getPOS {

    ### Hold the current word ###
    my $currentWord = $_[0];

    ### Holds the previous word ###
    my $lastWord = $_[1];

    ### Will store the previous POS ###
    my $prevPOS;

    ### Variable to store the max of a given probability so we can later assign it to POS ###
    my $max;

    ### Our POS guess ###
    my $POS;

    ### We check to see if a last word is defined because if it is, we will compute its POS. If not we will just call it a noun ###
    if (defined $lastWord) { $prevPOS = getPOS($lastWord); } 
        else { $prevPOS = "NN"; }

    ### If the current word is a number then just assign it the tag 'CD' ###
    if($currentWord =~ /^(?=.)(\d{1,3}(,\d{3})*)?(\.\d+)?$|(\d\\\/\d)/) { return "CD"; } 

    ### If the current word is a time then also assign it the tag 'CD' ###
    if($currentWord =~ /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/) { return "CD";} 
    
    ### Let us start by assuming our POS is a Noun ###
    $POS = "NNP";

    ### If we have seen the word before ###
    if(exists $wordToPOSMapping{$currentWord}) {

        ### Set the max to zero ###
        $max = 0;

        ### Let us loop through all the possible POS tags we have stored for that word ###
        for my $value ( keys %{ $wordToPOSMapping{$currentWord} } ) {

            ### This is how many times the POS tag appeared in our training data ###
            my $frequencyTableValue;

            ### This is how many time a POS tag was seen given its previous tag ###
            my $POSMapping;

            ### This is how many times the current word was seen with the given POS tag. ###
            my $currentMap;

            ### If have a frequency table value then set it else just move on so we dont divide by zero ###
            if(exists $frequencyTable{$value}) { $frequencyTableValue =  $frequencyTable{$value}; } 
                else { next; }

            ### If have a previous POS value then set it else just move on because we know the result will be zero ###
            if(exists $POStoPOSMapping{$value}{$prevPOS}) { $POSMapping = $POStoPOSMapping{$value}{$prevPOS}; } 
                else { next; }

            ### If have a relationship with the current word then set it else just move on because we know the result will be zero ###
            if(exists $wordToPOSMapping{$currentWord}{$value}) { $currentMap = $wordToPOSMapping{$currentWord}{$value}; } 
                else {  next; }

            ### Now we can calculate the probabilty the current POS tag is the one we need ###
            my $argMax = (($currentMap * $POSMapping)/$frequencyTableValue);
            
            ### If the result of our caluculation was bigger than the current max, make it the current max and make it our POS tag.    
            if($argMax > $max) {
                $max = $argMax;
                $POS = $value;
            }
        }

        ### Return the maximum possible POS tag. ###
        return $POS;
    }

    ### We have not seen the word before ###
    else { 
            
            ### If the word contains a hypen, it usually, but not always, represents an acjective so lets just assume it is.           
            if($currentWord =~ /\w+-\w+/) { return "JJ"; } 
                
            ### Assume that most adverbs end in ly ###              
            if($currentWord =~ /\b\w+(ly\b)/) { return "RB"; } 

            ### Since we are assuming a noun (singular), adding an 's' would give us a noun plural. ###
            if($currentWord =~ /\b\w+(s\b)/) { return "NNS"; } 

            ### Past tense verbs most of the time end in 'ed' ###
            if($currentWord =~ /\b\w+(ed\b)/) { return "VBN"; } 

            ### If we see an interjection, just label it ###
            if($currentWord =~ /\boh\b|\bah\b/i) { return "UH"; } 

            ### If the word ends in 'ing' there is a good chance its a verb ###
            if($currentWord =~ /\b\w+(ing\b)/) { return "VBG"; } 

            ### If all else fails, just call it a noun ###
            return "NNP";
    }    
}