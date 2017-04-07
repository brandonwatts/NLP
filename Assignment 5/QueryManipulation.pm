package QueryManipulation;
use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );

# these are exported by default.
our @EXPORT = qw( parseQuery getQuerySubject getVariations getQueryType getQueryModifier getSubjectModifier );

sub parseQuery {
	$query = $_[0];
	$query =~ s/[\.?!]//g;
	return $query;
}

sub getQuerySubject {
	my $query = $_[0];
	if($query =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+).*/) {
        return $1." ".$2;
    }
    return "UNIDENTIFIABLE SUBJECT";
}

sub getVariations {
	my $subject = $_[0];
	my @variations = ();

	if($subject =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+)/) {
        push(@variations, $1);
        push(@variations, $2);
        push(@variations, $1." ".$2);
    }

    return @variations;
}

sub getQueryType {
    my $query = $_[0];
    my $queryType;
    if($query =~ /^Who/i) {
        $queryType = "Who";
    }
    elsif($query =~ /^What/i) {
        $queryType = "What";
    }
    elsif($query =~ /^When/i) {
        $queryType = "When";
    }
    elsif($query =~ /^Where/i) {
        $queryType = "Where";
    } 
    else {
        $queryType = "UNDETERMINED";
    }

    return $queryType;
}

sub getQueryModifier{
    my $query = $_[0];
    my $queryType = getQueryType($query);
    my $queryModifier;
    
    switch ($queryType) {
        case "Who" {
            if($query =~ /^Who\s(\w+)\s/i) {
                $queryModifier = $1;
            }
        }
        case "When" {
             if($query =~ /^When\s(\w+)\s/i) {
                $queryModifier = $1;
            }
        }
        case "Where" {
             if($query =~ /^Where\s(\w+)\s/i) {
                $queryModifier = $1;
            }
        }
        case "What" {
             if($query =~ /^What\s(\w+)\s/i) {
                $queryModifier = $1;
            }
        } else {
            return "NO MODIFIER FOUND";
        }
    }

    return $queryModifier;
}

sub getSubjectModifier{
    my $query = $_[0];
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
                $queryModifier = $1;
                $subjectModifier = $';
            }
        } else {
            return "NO SUBJECT MODIFIER FOUND";
        }
    }

    return $subjectModifier;
}

1;