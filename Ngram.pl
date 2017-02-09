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

say("The frequency of Brandon is: ". getFrequency("Brandon is","<END>"));

close(FILE);

#going to fix off by 1
sub createNgramMapping {
    $sentence  = $_[0];
    $sliceSize = $_[1];
    my @words = split("\w+|[^\w\s]", $sentence );

    unshift( @words, "<START>" );
    push( @words, "<END>" );
    foreach my $i ( 1 .. $#words ) {
        if ( $words[$i] =~ m/(<START>|<END>)/ ) {
            next;
        } else {
            @tempArray = ();
            foreach my $j ( 0 .. $sliceSize - 2 ) {
            push( @tempArray, $words[ $i + $j ] );
        }
        $key = join( " ", @tempArray );
        if ( $i + $#tempArray - 1 > $#words || $key =~ m/(<START>|<END>)/) {
            next;
        } else {
            insertNgramMapping( $key, $words[ $i + $#tempArray+1 ] );
        }
     }
}

sub process {
    $inputString = $_;
    @inputWords = split( " ", $inputString );
    foreach my $word (@inputWords) {
        insertFrequecyTable($word);
    }
    createNgramMapping( $inputString, 2 );
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

sub printRawFrequencyTable {\
say "---------------------- Raw Frequency Table ----------------------------";
    foreach my $key ( keys %rawfrequencyTable ) {    # Loop through the dictionary
        say "KEY: $key \t VALUE: $rawfrequencyTable{$key}";
    }
}

sub printFrequecyTable {
    say "---------------------- Frequency Table ----------------------------";
    foreach my $key ( keys %frequencyTable ) {    # Loop through the dictionary
        say "KEY: $key \t VALUE: $frequencyTable{$key}";
    }
}

sub printNgramMapping {
    say "---------------------- NGram Mapping ----------------------------";
    foreach my $key ( keys %NgramMapping ) {      # Loop through the dictionary
        say "KEY: $key \t VALUE: $NgramMapping{$key}";
    }
}
}