#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 3
# 2/22/17

use warnings;
use feature qw(say switch);
use File::Slurp;
use strict;

### Training data file ###
my $taggedFile = read_file($ARGV[0]);

### Test data file ###
my $key = read_file($ARGV[1]);

my %confusionMatrix;

my @tokensForKey;
    my @POSForKey;
    my @tokensForTagged;
    my @POSForTagged;

processKey($key);
processTagged($taggedFile);
computeAccuracy();
   
sub processKey {
    
    my $outputFile = "test.txt";

    my $rawData = $_[0];
    $rawData =~ s/\[|\]/ /g;
    $rawData =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    my @sentenceTokens = $rawData=~ /\S+/g;    
    foreach my $i (0.. $#sentenceTokens ) {
        append_file($outputFile, "$sentenceTokens[$i]\n"); 
       if ($sentenceTokens[$i] =~ /(\S+)\\?\/(\S+)/) { 
        $tokensForKey[$i] = $1; 
        $POSForKey[$i] = $2;
       } 
    }
}

sub processTagged {
    my $rawData = $_[0];

    my @sentenceTokens = $rawData=~ /\S+/g;
    
    foreach my $i (0.. $#sentenceTokens ) {

       if ($sentenceTokens[$i] =~ /(\S+)\\?\/(\S+)/){ 

        $tokensForTagged[$i] = $1; 
        $POSForTagged[$i] = $2;
       } 
    }
}

sub computeAccuracy {

    my $true = 0;
    my $false = 0;
    my $breakingWord;

    foreach my $i (0.. $#POSForTagged ) {
        
        if ($POSForTagged[$i] eq $POSForKey[$i]) { 
                $true++;
       } else {
                $false++;
                $confusionMatrix{$tokensForTagged[$i]}{$POSForKey[$i]} = $POSForTagged[$i];
            }
    }

    say "---------------------- Confusion Matrix ----------------------------";

    for my $key ( keys %confusionMatrix ) {
        
        for my $value ( keys %{ $confusionMatrix{$key} } ) {
            say "---------------------------------------------------------------------------------------------";
            printf("Word: %-20s | Chose: %-20s | Correct: %-20s\n", $key,$confusionMatrix{$key}{$value} ,$value);
            say "---------------------------------------------------------------------------------------------";
        }

        print "\n";
    }

       my $correctPercentage = $true/$#POSForTagged;
        my $incorrectPercentage = $false/$#POSForTagged;
    print("Percentage Correct: $correctPercentage\n");
    print("Percentage Incorrect: $incorrectPercentage\n");
}


