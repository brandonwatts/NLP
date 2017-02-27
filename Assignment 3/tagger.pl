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
   #printFrequecyTable();
    #printRawFrequencyTable();
    #printPOStoPOSTable();
    generateTaggedFile($testData);



#  Method that initializes the program 
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub preprocess {

    my $rawData = $_[0];
    $rawData =~ s/\[|\]//g;
    $rawData =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
    $rawData =~ s/^\s+|\s+$//g; # Trim the file

    createFrequencyTable($rawData);
    createWordtoPOSMapping($rawData);
    createPOStoPOSMapping($rawData);
}

#  Method that maps all the POS tags the the frequency in which they occur in the file
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createFrequencyTable {

    my $file = $_[0];
    my @POS = $file=~ /[-`$%&(\\\/)'':\.,'\w+]+\\?\/([-`$%&(\\\/)'':\.,'\w+]+)/g; # Grab all the POS tags, semicolons, commas, and periods and place them in an array
       

          # print join("\n",@POS),"\n";

    ### Iterate over that array and count the number of times a tag has been seen ###
    for my $pos (@POS) { $frequencyTable{$pos}++; }
}

#  Method that maps all the words/tokens with thier respective POS tag
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createWordtoPOSMapping {
    my $data = $_[0];
    my @sentenceTokens = $data=~ /[-`$%&(\\\/)'':\.,'\w+]+\\?\/[-`$%&(\\\/)'':\.,'\w+]+/g;

    for my $token (@sentenceTokens) {

        ### Seperate the word from the POS into 2 capture groups ###
         if ($token =~ /([-`$%&'':\.,'\w+]+)\\?\/([-`$%&'':\.,'\w+]+)/) { $wordToPOSMapping{$1}{$2}++; }
    }
}

#  Method that maps all the POS tags with thier previous POS tag
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createPOStoPOSMapping {
    my $rawData = $_[0];

    ### Regex to grab just the POS tag in a capture group ###
    my @sentenceTokens = $rawData=~ /[-`$%&(\\\/)'':\.,'\w+]+\\?\/([-`$%&(\\\/)'':\.,'\w+]+)/g;
    



    foreach my $i (1.. $#sentenceTokens ) {
        $POStoPOSMapping{$sentenceTokens[$i]}{$sentenceTokens[$i-1]}++;
    }
}

#  Method that generates the tagged output file 
#
#  @param $_[0]  Will hold the Trst data file in its entirety
sub generateTaggedFile {

    my $file = $_[0];
    $file =~ s/\[|\]//g;
    $file =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
    my $outputFile = "pos-test-with-tags.txt";
    print $file;

    my @sentenceTokens = $file=~ /[-`$%&'':\.,'\w+]+/g;
    my @sentenceTokensPOS;
    write_file($outputFile,"");

    foreach my $i (0.. $#sentenceTokens ) {
              my $POSGuess = getPOS($sentenceTokens[$i]);
        append_file( $outputFile, "$sentenceTokens[$i]/$POSGuess\n");
    }

}

#  Method that get a POS tag given a word and its previous POS
#
#  @param $_[0]   
sub getPOS {
    my $currentWord = $_[0];
    my $max;
    my $POS = "NN";
    my $prevPOS = "NN";

       if(exists $wordToPOSMapping{$currentWord}) {
            $max = 0;
            for my $value ( keys %{ $wordToPOSMapping{$currentWord} } ) {

                my $frequencyTableValue;
                my $POSMapping;
                my $currentMap;

                if(exists $frequencyTable{$value}) {
                    $frequencyTableValue =  $frequencyTable{$value};
                } else {
                    $frequencyTableValue = 1;
                }

                if(exists $POStoPOSMapping{$value}{$prevPOS}) {
                   $POSMapping = $POStoPOSMapping{$value}{$prevPOS};
                } else {
                    $POSMapping = 0;
                }


                if(exists $wordToPOSMapping{$currentWord}{$value}) {
                   $currentMap = $wordToPOSMapping{$currentWord}{$value};
                } else {
                    $currentMap = 0;
                }


                my $argMax = ($currentMap/$frequencyTableValue)*($POSMapping/$frequencyTableValue);
                        $POS = $value;
                if($argMax > $max) {
                        $max = $argMax;
                }
            }
            return $POS;
        }
        else { return "NN"; }
}

sub printFrequecyTable {

    say "---------------------- Frequency Table ----------------------------";

    foreach my $key ( keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $frequencyTable{$key});
    }
}

sub printRawFrequencyTable {
    say "---------------------- Word To POS Frequency Table ----------------------------";

    for my $key ( keys %wordToPOSMapping ) {
        
        print "$key: ";

        for my $value ( keys %{ $wordToPOSMapping{$key} } ) {
            print "$value=$wordToPOSMapping{$key}{$value} ";
        }

        print "\n";
    }
}

sub printPOStoPOSTable {
    say "---------------------- POS To POS Frequency Table ----------------------------";

    for my $key ( keys %POStoPOSMapping ) {
        
        print "$key: ";

        for my $value ( keys %{ $POStoPOSMapping{$key} } ) {
            print "$value=$POStoPOSMapping{$key}{$value} ";
        }

        print "\n";
    }
}




