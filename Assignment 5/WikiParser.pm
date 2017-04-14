package WikiParser;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Wiki Parser
# 4/10/17

######## SUMMARY #########

# This is a package created to assist with parsing the data returned by WWW::Wikipedia

use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT = qw( parseWikiData );

#  Method that attempts to parse Query Data into sentences split by a single space.
#  @param $_[0]  The raw text returned from the wiki entry
sub parseWikiData{
    my $data = $_[0];

    $data =~ s/\s+/ /g;

    ##### Remove Phoenatic speellign and birthdate #####
    $data =~ s/\(;.*,\s\d\d\d\d\)//;

    $data =~ s/\{\{Infobox.*\}\}\s'//g;

    ##### Delete all the reference tags #####
    $data =~ s/<ref>|<\/ref>|<ref .*\/?>//g;

    ##### Delete all the break tags #####
    $data =~ s/<br>|<br \/>//g;

    ##### Delete everything that is not a letter or a period #####
    $data =~ s/[^a-zA-Z0-9\.]/ /g; 

    ##### Delete all the extra tabs and spaces#####
    $data =~ s/\s+/ /g;

    ##### Used for Abbreviations - We delete periods so we dont mistake them for sentence endings. #####
    #$data =~ s/([A-Z])\.([A-Z])\./$1$2/g;

    return $data;
}
1;