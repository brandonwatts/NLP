package QueryManipulation;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Query Manipulation
# 4/11/17

######## SUMMARY #########

# This is a package created to assist with query rewrites

use warnings;
use Switch;
use Exporter;
use Lingua::EN::NamedEntity;
use String::Util;


our @ISA= qw( Exporter );
our @EXPORT = qw( parseQuery getExpectedAnswer getQuerySubject getVariations getQueryType getQueryModifier getSubjectModifier getRemainsFromSubjectExtraction );

#  Method that parses a query to remove punctuation 
#
#  @param $_[0]  The Query
sub parseQuery {
	$query = $_[0];
	$query =~ s/[\.?!]//g;
	return $query;
}

#  Method that breaks a name up into its variations. For example "George Washington" can be reffered to as "George" or "Washington"
#
#  @param $_[0]  The Subject
sub getVariations {
	my $subject = $_[0];
    my $subjectType = $_[1];
	my @variations = ();

    ##### If the naem is 2 parts break it up #####
	if ($subjectType eq "person"){
        if($subject =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+)/) {
            push(@variations, $1." ".$2);
            push(@variations, $1);
            push(@variations, $2);
            push(@variations, "He");
            push(@variations, "She");
        }
    }
    else { 
        push(@variations, $subject);
    }

    return @variations;
}

sub getExpectedAnswer {
    my $query = $_[0];

    ##### Get the query type #####
    my $queryType = getQueryType($query);

    my $expectedAnswer;
    switch ($queryType) {
        case "Who" {
            $expectedAnswer = "PERSON";
        }
        case "When" {
            $expectedAnswer = "DATE";
        }
        case "Where" {
            $expectedAnswer = "LOCATION"; 
        }
        case "What" {
           $expectedAnswer = "OBJECT"; 
        } 
        else {
            return "NO EXPECTED ANSWER";
        }
    }

    return $expectedAnswer;
}



#  Method that returns what type of query we are dealign with
#
#  @param $_[0]  The Query
sub getQueryType {
    my $query = $_[0];
    my $queryType;

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
sub getQuerySubject {
    my $query = $_[0];
    my $subjectModifier;
    my $subjectType; 


    my @entities = extract_entities($query);
            foreach my $entity (@entities){
                    $subjectModifier = $entity->{entity};
                    $subjectType = $entity->{class}
                }

     if ( scalar @entities == 0){
            my $q = getSubjectModifier($query);
            my @phrases = $q =~ /[A-Z][a-z]+/g;
            return $phrases[0], "object";
    } else {
        return "$subjectModifier", $subjectType;
    }
}

#  Method that get the modiefier of a query such as : "is","was"..etc.
#
#  @param $_[0]  The Query
sub getQueryModifier{
    my $query = $_[0];

    ##### Get the query type #####
    my $queryType = getQueryType($query);

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

    ##### Get the Query Type #####
    my $queryType = getQueryType($query);

    my $subjectModifier;
    switch ($queryType) {
        case "Who" {
             if($query =~ /^Who\s(\w+)\s/i) { 
                $subjectModifier = $';
            }
        }
        case "When" {
             if($query =~ /^When\s(\w+)\s/i) { 
                $subjectModifier = $';
            }
        }
        case "Where" {
             if($query =~ /^Where\s(\w+)\s/i) {   
                $subjectModifier = $'; 
            }
        }
        case "What" {
             if($query =~ /^What\s(\w+)\s/i) {   
                $subjectModifier = $'; 
            }
        } 
        else {
            return ("NO SUBJECT MODIFIER FOUND");
        }
    }

    return ($subjectModifier);
}
1;