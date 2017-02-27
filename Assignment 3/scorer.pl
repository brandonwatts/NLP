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
    $rawData =~ s/\[|\]//g;
    $rawData =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
    $rawData =~ s/^\s+|\s+$//g; # Trim the file

    my @sentenceTokens = $rawData=~ /[-`$%&(\\\/)'':\.,'\w+]+\\?\/[-`$%&(\\\/)'':\.,'\w+]+/g;    
    foreach my $i (0.. $#sentenceTokens ) {
        append_file($outputFile, "$sentenceTokens[$i]\n"); 
       if ($sentenceTokens[$i] =~ /([-`$%&'':\.,'\w+]+)\/([-`$%&'':\.,'\w+]+)/) { 
        $tokensForKey[$i] = $1; 
        $POSForKey[$i] = $2;
       } 
    }
}

sub processTagged {
    my $rawData = $_[0];

    my @sentenceTokens = $rawData=~ /[-`$%&(\\\/)'':\.,'\w+]+\\?\/[-`$%&(\\\/)'':\.,'\w+]+/g;
    
    foreach my $i (0.. $#sentenceTokens ) {

       if ($sentenceTokens[$i] =~ /([-`$%&'':\.,'\w+]+)\/([-`$%&'':\.,'\w+]+)/) { 

        $tokensForTagged[$i] = $1; 
        $POSForTagged[$i] = $2;
       } 
    }
}

sub computeAccuracy {

    my $true = 0;
    my $false = 0;

    foreach my $i (0.. $#POSForTagged ) {
        if ($POSForTagged[$i] eq $POSForKey[$i]) { 
                $true++;
       } else {
                $false++;
            }
    }

    print("TRUE: $true");
    print("FALSE: $false")
}


