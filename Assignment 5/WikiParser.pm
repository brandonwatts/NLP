package WikiParser;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Wiki Parser
# 4/10/17

######## SUMMARY #########

# This program is a rudimentary Question and answering system using Wikipedia as a backend. It attempts to answer four basic 
# types of questions: Who, What, When or Where by means of query rewriting and direct regex matching.

######### ALGORITHIMS ########

#   There were really no major alogorithims used in this iteration of the QA system but I will decribe the method by which I 
#   turned a query into a response.
#
#   1) 
#   2) 
#   3) 
#   4) 

########## REFERENCES #########
# Exporter - http://perldoc.perl.org/Exporter.html
# Switch - http://perldoc.perl.org/5.8.8/Switch.html

use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT = qw( parseWikiData );

#  Method that attempts to parse Query Data into sentences split by a single space.
#  @param $_[0]  The raw text returned from the wiki entry
sub parseWikiData{
    my $data = $_[0];

    ##### Delete all the reference tags #####
    $data =~ s/<ref>|<\/ref>|<ref//g;

    ##### Delete the author tags #####
    $data =~ s/name="?.*"?>//g;

    ##### Delete everything that is not a letter or a period #####
    $data =~ s/[^a-zA-Z0-9\.]/ /g; 

    ##### Delete all the extra tabs and spaces#####
    $data =~ s/\s+/ /g;

    ##### Used for Abbreviations - We delete periods so we dont mistake them for sentence endings. #####
    $data =~ s/([A-Z])\.([A-Z])\./$1$2/g;

    return $data;
}
1;