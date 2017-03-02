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

my @POSkey = ("CC","CD","DT","EX","FW","IN","JJ","JJR","JJS","LS","MD","NN","NNS","NNP","NNPS","PDT","POS","PRP","RB","RBR","RBS","RP","SYM","TO","UH","VB","VBD","VBG","VBN","VBP","VBZ","WDT","WRB");


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
    my @POS = $file=~ /\S+\\?\/(\S+)/g; # Grab all the POS tags, semicolons, commas, and periods and place them in an array
       

          # print join("\n",@POS),"\n";

    ### Iterate over that array and count the number of times a tag has been seen ###
    for my $pos (@POS) { $frequencyTable{$pos}++; }
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

#  Method that maps all the POS tags with thier previous POS tag
#
#  @param $_[0]  Will hold the Training data file in its entirety
sub createPOStoPOSMapping {
    my $rawData = $_[0];

    ### Regex to grab just the POS tag in a capture group ###
    my @sentenceTokens = $rawData=~ /\S+\\?\/(\S+)/g;
    



    foreach my $i (1.. $#sentenceTokens ) {
        $POStoPOSMapping{$sentenceTokens[$i]}{$sentenceTokens[$i-1]}++;
    }
}

#  Method that generates the tagged output file 
#
#  @param $_[0]  Will hold the Trst data file in its entirety
sub generateTaggedFile {

    my $file = $_[0];
    $file =~ s/\[|\]/ /g;
    $file =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
    my $outputFile = "pos-test-with-tags.txt";

    my @sentenceTokens = $file=~ /\S+/g;
    my @sentenceTokensPOS;

    foreach my $i (0.. $#sentenceTokens ) {
        
        my $POSGuess;

        if($i<1) {
                $POSGuess = getPOS($sentenceTokens[$i]);
            } else {
              $POSGuess = getPOS($sentenceTokens[$i],$sentenceTokens[$i-1]);
            }
        append_file( $outputFile, "$sentenceTokens[$i]/$POSGuess\n");
    }

}

#  Method that get a POS tag given a word and its previous POS
#
#  @param $_[0]   
sub getPOS {
    my $currentWord = $_[0];
    my $lastWord = $_[1];
    my $prevPOS;
    my $max;
    my $POS;

    if (defined $lastWord) {
        $prevPOS = getPOS($lastWord);
    } else {
        $prevPOS = "NN";
    }


            $POS = "NNP";
    
    


    
                if($currentWord =~ /^(?=.)(\d{1,3}(,\d{3})*)?(\.\d+)?$|(\d\\\/\d)/) {
                    return "CD";
                } 

                if($currentWord =~ /^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/) {
                    return "CD";
                } 

       if(exists $wordToPOSMapping{$currentWord}) {

            $max = 0;
            for my $value ( keys %{ $wordToPOSMapping{$currentWord} } ) {



                my $frequencyTableValue;
                my $POSMapping;
                my $currentMap;

                if(exists $frequencyTable{$value}) {
                    $frequencyTableValue =  $frequencyTable{$value};
                } else {
                    next;
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

                my $argMax = (($currentMap * $POSMapping)/$frequencyTableValue);
                if($argMax > $max) {
                        $max = $argMax;
                        $POS = $value;
                }
        }
            return $POS;
        }
        else { 
                if($currentWord =~ /\w+-\w+/) {
                    return "JJ";
                } 
                
                if($currentWord =~ /\b\w+(ly\b)/) {
                    return "RB";
                } 

                if($currentWord =~ /\b\w+(s\b)/) {
                    return "NNS";
                } 

                if($currentWord =~ /\b\w+(ed\b)/) {
                    return "VBN";
                } 

                if($currentWord =~ /\boh\b|\bah\b/i) {
                    return "UH";
                } 

                 if($currentWord =~ /\b\w+(ing\b)/) {
                    return "VBG";
                } 


                return "NNP";
        }
            
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




