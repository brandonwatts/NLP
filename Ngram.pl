#! usr/bin/perl

# Brandon Watts
# CMSC 416
# Assignment 2
use warnings;
use feature qw(say switch);

my %frequencyTable;
my %NgramMapping;
my %rawfrequencyTable;
my @NgramMatrix;
my @FILES = @ARGV;

$filename = $ARGV[0];

open( FILE, $filename ) or die "Couldn't open $filename";
while (<FILE>) {
    chomp();
    my $currentLine = $_;
    process($currentLine);
}

printFrequecyTable();
printNgramMapping();
printRawFrequencyTable();

close(FILE);

#going to fix off by 1
sub createNgramMapping {
    $sliceSize  = $_[0];
    @sentenceWords = @{$_[1]}; 
    unshift( @sentenceWords, "<START>" );
    push( @sentenceWords, "<END>" );
    foreach my $i ( 0.. $#sentenceWords ) {
        @tempArray = ();
        if ( $sentenceWords[$i] =~ m/(<START>|<END>)/ ) {
            next;
       } 
       else {
        $startingPoint = $i - $sliceSize < 1 ? -1 : $i - $sliceSize;
        if ($startingPoint == -1)
        {
            next;
        }
        else {
        for my $j($startingPoint...$i-1) {
            push (@tempArray, $sentenceWords[$j]);
        }
    }
       }
        $key = join(" ", @tempArray );
        insertNgramMapping( $key, $sentenceWords[$i]);
     }
}

sub process {
    $inputString = $_;
    @inputWords = $inputString =~ /[\w']+|[.,!?;]/g;
    foreach my $word (@inputWords) {
        insertFrequecyTable(lc($word));
    }
    createNgramMapping(2, \@inputWords);
}

sub insertFrequecyTable {
    $inputWord = $_[0];
    $frequencyTable{$inputWord}++;
}

sub insertNgramMapping {
    $key                = $_[0];
    $value              = $_[1];
    $NgramMapping{$key} = $value;
    $rawfrequencyTable{$key."|".$value}++;
}

sub getFrequency {
	if (@_==1) {
	    return $frequencyTable{$_[0]};
	} else {
	    return $rawfrequencyTable{$_[0]."|".$_[1]};
	} 
}

sub printRawFrequencyTable {
say "---------------------- Raw Frequency Table ----------------------------";
    foreach my $key ( keys %rawfrequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-15s VALUE: %-15s\n", $key, $rawfrequencyTable{$key});
    }
}

sub printFrequecyTable {
    say "---------------------- Frequency Table ----------------------------";
    foreach my $key ( keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-15s VALUE: %-15s\n", $key, $frequencyTable{$key});
    }
}

sub printNgramMapping {
    say "---------------------- NGram Mapping ----------------------------";
    foreach my $key ( keys %NgramMapping ) {      # Loop through the dictionary
        printf("KEY: %-15s VALUE: %-15s\n", $key, $NgramMapping{$key});
    }
}