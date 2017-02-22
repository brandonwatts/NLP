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



my %frequencyTable;
my %wordToPOSMapping;
my %POStoPOSMapping;
my $trainingData = read_file($ARGV[0]);
my $testData = read_file($ARGV[1]);


preprocess($trainingData);
    #printFrequecyTable();
    #printRawFrequencyTable();
    #printPOStoPOSTable();
    generateTaggedFile($testData);


sub generateTaggedFile {
    my $file = $_[0];
    $file =~ s/\[|\]//g;
    my @sentenceTokens = $file=~ /\b[A-Z]+[a-z]+\b|\d*\.\d*/g;
    my @sentenceTokensPOS;

    foreach my $i (1.. $#sentenceTokens ) {
        getPOS($sentenceTokens[$i]); 
    }

}


sub getPOS {
    my $currentWord = $_[0];
    my $max;
    my $POS = "NN";
    my $prevPOS = "NN";

       if(exists $wordToPOSMapping{$currentWord}) {
            $max = 0;
            for my $value ( keys %{ $wordToPOSMapping{$currentWord} } ) {
                if($wordToPOSMapping{$currentWord}{$value} > $max) {
                        $max = ($wordToPOSMapping{$currentWord}{$value}/$frequencyTable{$value})*($POStoPOSMapping{$prevPOS}{$value}/$frequencyTable{$value});
                        $POS = $value;
                }
            }
            print $POS."\n";
        }
        else {
            print "THERE ARE NO KEYS\n"
        }
        
}




sub preprocess {
    my $rawData = $_[0];
    $rawData =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
    $rawData =~ s/\[|\]//g;
    
    $rawData =~ s/^\s+|\s+$//g;
    createFrequencyTable($rawData);
    createWordtoPOSMapping($rawData);
    createPOStoPOSMapping($rawData);
    
}

sub createWordtoPOSMapping {
    my $data = $_[0];
    my @sentenceTokens = $data=~ /\w+\/\w+/g;

    for my $token (@sentenceTokens)
    {
         if ($token =~ /(\w+)\/([A-Z]+|[\.,])/) {
                $wordToPOSMapping{$1}{$2}++;
        }
    }

}

sub createPOStoPOSMapping {
    my $rawData = $_[0];
    my @sentenceTokens = $rawData=~ /[\w\.,]\/(\w+)/g;
    foreach my $i (1.. $#sentenceTokens ) {
        $POStoPOSMapping{$sentenceTokens[$i]}{$sentenceTokens[$i-1]}++;
    }
}

sub createFrequencyTable {

    my $file = $_[0];
    my @POS = $file=~ /\/([A-Z]+|[\.,])/g;
       
       #print join("\n",@POS),"\n";

    for my $pos (@POS) {
        $frequencyTable{$pos}++;}
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




