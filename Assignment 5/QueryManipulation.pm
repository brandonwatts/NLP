package QueryManipulation;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Query Manipulation
# 4/11/17

######## SUMMARY #########

# Th

######### ALGORITHIMS ########

#   There were really no major alogorithims used in this iteration of the QA system but I will decribe the method by which I 
#   turned a query into a response.
#
#   1) 
#   2) 
#   3) 
#   4) 

########## REFERENCES #########

use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT = qw( parseQuery getQuerySubject getVariations getQueryType getQueryModifier getSubjectModifier );

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub parseQuery {
	$query = $_[0];

    ##### #####
	$query =~ s/[\.?!]//g;

	return $query;
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub getQuerySubject {
	my $query = $_[0];

    ##### #####
	if($query =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+).*/) {
        return $1." ".$2;
    }

    ##### #####
    elsif($query =~ /([A-Z][a-z]+)/) {
        return $1;
    }

    return "UNIDENTIFIABLE SUBJECT";
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub getVariations {
	my $subject = $_[0];

    ##### #####
	my @variations = ();

    ##### #####
	if($subject =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+)/) {
        push(@variations, $1." ".$2);
        push(@variations, $1);
        push(@variations, $2);
    }

    ##### #####
    elsif ($subject =~ /([A-Z][a-z]+)/) { push(@variations, $1); }

    return @variations;
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub getQueryType {
    my $query = $_[0];

    ##### #####
    my $queryType;

    ##### #####
    if     ($query =~ /^Who/i)   { $queryType = "Who"; }
    elsif  ($query =~ /^What/i)  { $queryType = "What"; }
    elsif  ($query =~ /^When/i)  { $queryType = "When"; }
    elsif  ($query =~ /^Where/i) { $queryType = "Where"; } 
    else                         { $queryType = "UNDETERMINED";}

    return $queryType;
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub getQueryModifier{
    my $query = $_[0];

    ##### #####
    my $queryType = getQueryType($query);

    ##### #####
    my $queryModifier;
    
    switch ($queryType) {
        case "Who" {
            if($query =~ /^Who\s(\w+)\s/i) { $queryModifier = $1; }
        }
        case "When" {
            if($query =~ /^When\s(\w+)\s/i) { $queryModifier = $1; }
        }
        case "Where" {
            if($query =~ /^Where\s(\w+)\s/i) { $queryModifier = $1; }
        }
        case "What" {
            if($query =~ /^What\s(\w+)\s/i) { $queryModifier = $1; }
        } 
        else {
            return "NO MODIFIER FOUND";
        }
    }

    return $queryModifier;
}

#  Method that obtains the subject from a query.
#
#  @param $_[0]  The Query
sub getSubjectModifier{
    my $query = $_[0];

    ##### #####
    my $queryType = getQueryType($query);

    ##### #####
    my $subjectModifier;
    
    ##### #####
    switch ($queryType) {
        case "Who" {
            if($query =~ /^Who\s(\w+)\s/i) { $subjectModifier = $'; }
        }
        case "When" {
             if($query =~ /^When\s(\w+)\s/i) { $subjectModifier = $'; }
        }
        case "Where" {
             if($query =~ /^Where\s(\w+)\s/i) { $subjectModifier = $'; }
        }
        case "What" {
             if($query =~ /^What\s(\w+)\s/i) { $subjectModifier = $'; }
        } 
        else {
            return "NO SUBJECT MODIFIER FOUND";
        }
    }

    return $subjectModifier;
}


sub getExpectedAnswer{
    my $query = $_[0];
    my $queryType = getQueryType($query);
    my $expectedAnswer;
    switch ($queryType) {
        case "Who" {
            $expectedAnswer = "<PERSON>";
        }
        case "What" {
            $expectedAnswer = "<OBJECT>";
        }
        case "When" {
            $expectedAnswer = "<DATE>";
        }
        case "Where" {
            $expectedAnswer = "<LOCATION>";
        }
    }
    return $expectedAnswer;
}

1;