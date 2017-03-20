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

######## ACCURACY AND RULES ########

# Becuase my program also used the previous tag to make its calculations, my accuray was able to climb to about a 90.5%
#
# I still added a few basic grammar rules so I wouldnt make the assumption that a word I hadnt seen was always a Noun.
#
# 1) If the word contains a hypen, it usually, but not always, represents an acjective so lets just assume it is.                      
# 2) Assume that most adverbs end in ly             
# 3) Since we are assuming a noun (singular), adding an 's' would give us a noun plural.
# 4) Past tense verbs most of the time end in 'ed' 
# 5) If we see an interjection, just label it 
# 6) If the word ends in 'ing' there is a good chance its a verb

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
#use strict;

use File::Slurp;
use Data::Dumper;
use XML::Simple;
use List::Util;

my %frequencyTable;

my $data;


### Training data file ###
my $trainingData = read_file($ARGV[0]);

### Test data file ###
my $testData = read_file($ARGV[1]);

### Test data file ###
my $decisionList = read_file($ARGV[2]);

preprocess($trainingData);
#printFrequecyTable();

#  Method that initializes the program 
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub preprocess {

### Training data file ###
my $train = $_[0];

### Delete all of the brackets from the input file ###
    $train =~ s/<@>//g;
    $train =~ s/<p>//g;
    $train =~ s/<\/p>//g;
    $train =~ s/&//g;


   # create object
my $xml = new XML::Simple;

write_file("ex.txt",$train);
# read XML file
$data = $xml->XMLin($train);

write_file 'mydump.log', Dumper($data);

createFeatures();
printFrequecyTable();
}


#  Method that generates the tagged output file 
#
#  @param $_[0]  Will hold the Test data file in its entirety
sub createFeatures {
        my @surroundingWords;

     for $instance ( keys %$data->{lexelt}->{instance} ) {


        if (ref($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){
           foreach my $surroundingWords ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                push(@surroundingWords,$surroundingWords);
            } 
        } else {
            foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
                    foreach my $p (@$part){
                            if(ref($p) eq "HASH"){
                                foreach my $surroundingWords ($p->{content}){
                                   foreach my $s (@$surroundingWords){
                                        push(@surroundingWords,$s);
                                    }
                                }
                            }
                            else{
                               push(@surroundingWords,$p);
                            }
                    }
            }
        }
    }
    my $allWords = join(' ',@surroundingWords);
    $allWords =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    my @words = $allWords=~ /\S+/g;
     foreach my $word (@words) {
        $frequencyTable{$word}++; 
    }
}

sub printFrequecyTable {

    say "---------------------- Frequency Table ----------------------------";

    foreach my $key (sort {$frequencyTable{$b} <=> $frequencyTable{$a} or $b cmp $a } keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $frequencyTable{$key});
    }
}

