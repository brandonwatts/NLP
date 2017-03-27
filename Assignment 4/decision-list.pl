#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 3 - Tagger
# 3/2/17

use feature qw(say switch);
use warnings;

use File::Slurp;
use Data::Dumper;
use XML::Simple;
use List::Util;

my %frequencyTable;

my %topFrequencies;

my $data;

my %wordTypes;

my %guessedSenses;

my %wordsSurrounding;

my $trainingData = read_file($ARGV[0]);

my $testData = read_file($ARGV[1]);


preprocess($trainingData, $testData);

sub preprocess {

    my $train = $_[0];

    my $test = $_[1];

### Delete all of the brackets from the input file ###
    $train =~ s/<@>//g;
    $train =~ s/<p>//g;
    $train =~ s/<\/p>//g;
    $train =~ s/&//g;

### Delete all of the brackets from the input file ###
    $test =~ s/<@>//g;
    $test =~ s/<p>//g;
    $test =~ s/<\/p>//g;
    $test =~ s/&//g;

   # create object
    my $xml = new XML::Simple;

    # read XML file
    $data = $xml->XMLin($train);

    $testData = $xml->XMLin($test);

        write_file("ex.txt",Dumper($testData));


    createFeatures();
    createWordTypes();
    createWordsSurrounding("phone");
    createWordsSurrounding("product");
    computeSenseID();
    createAnswerFile();
}

#  Method that generates the tagged output file 
#
#  @param $_[0]  Will hold the Test data file in its entirety
sub createFeatures {
    
    my @surroundingWords;

    for $instance ( keys %$data->{lexelt}->{instance} ) {
        foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
            foreach my $p ($part) {
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

    my $allWords = join(' ',@surroundingWords);

    $allWords =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    my @words = $allWords=~ /\S+/g;
    foreach my $word (@words) { $frequencyTable{$word}++;}
}

sub createWordsSurrounding {
       
    my $senseid = $_[0];

    for $instance ( keys %$data->{lexelt}->{instance} ) {

        if ($data->{lexelt}->{instance}->{$instance}->{answer}->{senseid} eq $senseid){
           
           if (ref($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){
           
                foreach my $surroundingWords ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                    push(@surroundingWords,$surroundingWords);
                }
            }    
            else {
                foreach my $part ($data->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
                    foreach my $p (@$part){
                        if(ref($p) eq "HASH"){
                            foreach my $surroundingWords ($p->{content}){
                                foreach my $s (@$surroundingWords){
                                    push(@surroundingWords,$s);
                                }
                            }
                        }
                        else {
                            push(@surroundingWords,$p);
                        }
                    }
                }
            }
        }
    }

    my $allWords1 = join(' ',@surroundingWords);
    $allWords1 =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    $wordsSurrounding{$senseid} = $allWords1;
}

sub createWordTypes {

    for $instance ( keys %$data->{lexelt}->{instance} ) {

        my $senseid = $data->{lexelt}->{instance}->{$instance}->{answer}->{senseid};
        $wordTypes{$senseid}++;
    } 
}

sub getTimesWordOccuredWithFeature {
    my $searchWord = $_[0];
    my $senseid = $_[1];

    $wordsSurroundingFeature = $wordsSurrounding{$senseid};
    $wordsSurroundingFeature =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    my @individualWords = $wordsSurroundingFeature=~ /\S+/g;
    my $counter = 0;
    foreach my $word (@individualWords) {
        if($word eq $searchWord){
            $counter++;
        } 
    }
    return $counter;
}

sub computeSenseID {
        
    my $max;
    my $allWords = ();
    my @words =();
    my @surroundingWords = ();
    my @types = ("phone","product");
    my $guessedSense = "UNDETERMINED";

    ########## For Every instance ##########
    for $instance ( keys %$testData->{lexelt}->{instance}) {
        
        ########## Empty arrays from the previous instance  ##########
        $allWords = ();
        @words =();
        @surroundingWords = ();

        ########## The 2 senses the word "line" can have is "product" and "phone" ##########
        @types = ("product","phone");

        ########## Set the default sense to undetermined for easier debugging if a sense is not chosen ##########
        $guessedSense = "UNDETERMINED";

        ########## 's' can either be a hash or an array from the xml parser (not really sure why) so I have to check so I can access it the correct way ##########
        if (ref($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}) eq "HASH"){

           foreach my $surroundingWords ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'}->{content}){
                    push(@surroundingWords,$surroundingWords);
                }
        }
        ########## 's' was an array ########## 
        else {
            foreach my $part ($testData->{lexelt}->{instance}->{$instance}->{context}->{'s'} ) {
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

        $allWords = join(' ',@surroundingWords);
        $allWords =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.
        @words = $allWords=~ /\S+/g;
        my $max = 0;
        my $typeScore;
        foreach my $type (@types){
            $typeScore =1;
            foreach my $word (@words) {

                my $timesWordAppearedinTrainingData = $wordTypes{$type};

                my $TimesWordOccuredWithFeature = getTimesWordOccuredWithFeature($word,$type);

                if($TimesWordOccuredWithFeature == 0){
                    next;
                }
                $typeScore += log($TimesWordOccuredWithFeature/$timesWordAppearedinTrainingData);
            } 

            if (abs($typeScore) > $max) {
                $max = abs($typeScore);
                $guessedSense = $type;
            }
        }
 
        $guessedSenses{$instance} = $guessedSense;
    }

}

sub createAnswerFile {
    foreach $guess (keys %guessedSenses) {    # Loop through the dictionary
        printf(STDOUT "<answer instance=\"$guess\" senseid=\"$guessedSenses{$guess}\"/>\n");
    }
}

sub printWordTypes {

    say "---------------------- Word Types ----------------------------";

    foreach my $key (sort {$wordTypes{$b} <=> $wordTypes{$a} or $b cmp $a } keys %wordTypes ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $wordTypes{$key});
    }
}


sub printFrequecyTable {

    say "---------------------- Frequency Table ----------------------------";

    foreach my $key (sort {$frequencyTable{$b} <=> $frequencyTable{$a} or $b cmp $a } keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $frequencyTable{$key});
    }
}
sub printguess{
       foreach my $key (keys %guessedSenses ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $guessedSenses{$key});
    }
}

