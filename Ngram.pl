#! usr/bin/perl

# Brandon Watts
# CMSC 416
# Assignment 2
use warnings;
#use strict;
use feature qw(say switch);
use File::Slurp

my %frequencyTable;
my %NgramMapping;
my %rawfrequencyTableCount;
my %rawfrequencyTable;
my @NgramMatrix;

my $numberOfSentencesToGenerate =  $ARGV[1];

for(my $i=2; $i < @ARGV; $i++) {
    my $text = read_file($ARGV[$i]);
    process($text);
}

#print generateSentences(4);
printFrequecyTable();
printNgramMapping();
printRawFrequencyTable();

#going to fix off by 1
sub createNgramMapping {
    my $sliceSize  = $_[0];
    my @sentences = @{$_[1]};
    for my $sentence (@sentences)
    {
        my @sentenceTokens = $sentence =~ /[\w']+|[.,!?;]/g;
        unshift( @sentenceTokens, "<START>" );
        push( @sentenceTokens, "<END>" );
        foreach my $i (0.. $#sentenceTokens ) {
            @tempArray = ();
            $startingPoint = $i - $sliceSize < 0 ? -1 : $i - $sliceSize;
                if ($startingPoint == -1) {
                    next;
                }
                else {
                    for my $j($startingPoint...$i-1) {
                        push (@tempArray, $sentenceTokens[$j]);
                    }
                }
        my $key = join(" ", @tempArray );
        insertNgramMapping( $key, $sentenceTokens[$i]);
     }
    } 
}

sub createFrequencyTable {
    my $inputString = $_[0];
    my @inputWords = $inputString =~ /[\w']+|[.,!?;]/g;
    unshift( @inputWords, "<START>" );
    push( @inputWords, "<END>" );
    foreach my $word (@inputWords) {
        insertFrequecyTable(lc($word));
    }
}

sub process {
    my  $inputString = $_[0];
    $inputString =~ s/\s+|_/ /g;
    chomp($inputString);
    createFrequencyTable($inputString);
    my @inputSentences = $inputString =~ /\s+[^.!?]*[.!?]/g;    
    createNgramMapping(2, \@inputSentences);
}

#  Method to generate a sentence based off our N-gram models 
#
#  @param 0_[]  Will contain the next word in the sequence.
#  return       The completed sentence when a <End> tag is finally reached.
sub generateSentence { 
    my $currentWord = $_[0];
    my $sentence = $_[1];
    my %tempHash = ();
    my $normalizationFactor = 0; # Used to normalize the data set
    my $currentPositionOnNumberLine = 0;
    my @numberLine = ();
    my @numberLineValues =();

    if($currentWord =~ /[.!?]/) {
        return formatted($sentence);
    } else {

        for $value ( keys %{$rawfrequencyTable{"$currentWord"}}) {
            $normalizationFactor += $rawfrequencyTable{"$currentWord"}{$value};
        }
        for $value ( keys %{$rawfrequencyTable{"$currentWord"}}) {
            $tempHash{$value} = $rawfrequencyTable{"$currentWord"}{$value}/$normalizationFactor + $currentPositionOnNumberLine;
            $currentPositionOnNumberLine += $rawfrequencyTable{"$currentWord"}{$value}/$normalizationFactor;
        }
        push (@numberLineValues, 0);
        foreach my $token (sort { $tempHash{$a} <=> $tempHash{$b} } keys %tempHash) {
            push(@numberLine,$token);
            push (@numberLineValues, $tempHash{$token})
        }
        push (@numberLineValues, 2);
        $randNumber = rand();
        foreach my $i (1...$#numberLineValues-1) { 
            if($randNumber < $numberLineValues[$i] && $randNumber > $numberLineValues[$i-1]) {
                $nextWord = $numberLine[$i-1];
                $sentence = $sentence." ".$nextWord;
                last;
            }
        }
        #generateSentence($nextWord,$sentence);
    }
}

sub generateSentences {
    my $numberOfSentencesToGenerate = $_[0];
    foreach my $i(0... $numberOfSentencesToGenerate-1) {
        say generateSentence("<start>","");
    }
}

sub formatted {
    my $unformattedString = $_[0];
    $unformattedString =~ s/^\s+|\s+$//g;
    $unformattedString =~ s/([a-z])\s([.!?])/$1$2/g;
    $unformattedString = ucfirst($unformattedString);
    return $unformattedString;
}

sub insertFrequecyTable {
    my $inputWord = $_[0];
    $frequencyTable{$inputWord}++;
}

sub insertNgramMapping {
    my $key                = lc($_[0]);
    my $value              = lc($_[1]);
    $NgramMapping{$key} = $value;
    $rawfrequencyTableCount{$key."|".$value}++;
    $rawfrequencyTable{$key}{$value} = $rawfrequencyTableCount{$key."|".$value}/$frequencyTable{$value};
}

sub printRawFrequencyTable {
say "---------------------- Raw Frequency Table ----------------------------";
    for $key ( keys %rawfrequencyTable ) {
    print "$key: ";
    for $value ( keys %{ $rawfrequencyTable{$key} } ) {
         print "$value=$rawfrequencyTable{$key}{$value} ";
    }
    print "\n";
    }
}

sub printFrequecyTable {
    say "---------------------- Frequency Table ----------------------------";
    foreach my $key ( keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $frequencyTable{$key});
    }
}

sub printNgramMapping {
    say "---------------------- NGram Mapping ----------------------------";
    foreach my $key ( keys %NgramMapping ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $NgramMapping{$key});
    }
}
