#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 3 - Scorer
# 3/2/17

use File::Slurp;

use warnings;
use feature qw(say switch);
#use strict;
use XML::Simple;
use Data::Dumper;


### Training data file ###
my $answers = read_file($ARGV[0]);

### Test data file ###
my $key = read_file($ARGV[1]);

my %confusionMatrix;
my $answerHash;
my $keyHash;

processKey($key);
processAnswers($answers);
computeAccuracy();
   
sub processKey{
    my $key = $_[0];
    my $xml = new XML::Simple;
    $keyHash = $xml->XMLin($key);
    #write_file 'x.txt',Dumper($keyHash);
}

sub processAnswers{
    my $answers = $_[0];
    my $xml = new XML::Simple;
    $answerHash = $xml->XMLin($answers);
    #write_file 'ax.txt',Dumper($answerHash);
}

#  Method that will compute the accuacy, create a confusion matrix and output the data to the file specified.
sub computeAccuracy {

    my %keyMapping;
    foreach my $instances ($answerHash->{answer}){
            foreach my $id (@$instances){
               $keyMapping{$id->{instance}} = $id->{senseid};
            }
    }  

    my $true = 0;
    my $false = 0;
    my $total = 0;
    foreach my $instances ($answerHash->{answer}){
            foreach my $id (@$instances){
                if(($id->{senseid}) eq ($keyMapping{$id->{instance}})) {
                    $true++;
                    $total++;
                } else {
                    $false++;
                    $total++;
                }
                #say "For instance: ".$id->{instance}."I Choose: ".$id->{senseid}." The Correct answer is ". $keyMapping{$id->{instance}};
            }
    }
    say "Total Correct: $true";
    say "Total Incorrect: $false";
    $PercentageCorrect = $true/$total;
    $PercentageIncorrect = $false/$total;

    say "Percentage Correct: ".$PercentageCorrect*100;
    say "Percentage Incorrect: ".$PercentageIncorrect*100;

}