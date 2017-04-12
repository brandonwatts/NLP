#! usr/bin/perl

use warnings;
use strict;
use Switch;
use WWW::Wikipedia;
use feature qw(say);
use QueryManipulation;
use WikiParser;
use DocumentManipulation;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5
# 4/10/17

######## SUMMARY #########

# This program is a rudimentary Question and answering system using Wikipedia as a backend. It attempts to answer four basic 
# types of questions: Who, What, When or Where by means of query rewriting and direct regex matching.

########## EXAMPLE USE CASE #########

# $ perl qa-system.pl
# $ This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter "exit" to leave the program.
# $ Where is Orlando
# > Orlando is a city in the US state of Florida and the county seat of Orange County.
# $ exit

######### ALGORITHIMS ########

#   There were really no major alogorithims used in this iteration of the QA system but I will decribe the method by which I 
#   turned a query into a response.
#
#   1) 
#   2) 
#   3) 
#   4) 

########## REFERENCES #########


#####  #####
my $wiki = WWW::Wikipedia->new();

#####  #####
my $rankedNGrams;

#####  #####
my @documents;

#####  #####
my @FeatureVectorLabelingScheme;

#####  #####
my %documentToFeatureVector;

#####  #####
my @words; 

##### A Quick Greeting to the user #####
say "This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter \"exit\" to leave the program.";

while(<STDIN>){
  chomp;

  ##### Quit the program if the user types "exit" #####
  last if ($_ =~ /exit/); 

  ##### Get input from the user #####
  my $string = $_; 

  ##### Create an array of likey representations of the answers #####
  my @las = createLikelyAnswers($string);

  ##### Get the subject from the query #####
  my $subject = getSubjectModifier($string);

  ##### Array that holds the subject. It is an array because in part two there will be multiple subjects #####
  @words  = ("$subject");

  ##### Get the document/s from wikipedia regarding our subjects #####
  my $document = parseWikiData(getDocumet());
 
  ##### Boolean Variable to test if we have found the answer. #####
  my $foundAnswer = "false";

  ##### Document could not be obtained with the provided query
  if( $document eq "" ) {
    say "Answer could not be obtained with the provided query";
  }

  ##### We were able to obtain a document from Wiki ##### 
  else{

    ##### Loop through our likely answers an attempt to find a direct string match from our document #####
    for my $las (@las){

      ##### If our document contains our answer #####
      if ($document =~ /$las([^\.]*)/i) {

        ##### print the answer to the console #####
        print ("$las$1.\n");

        ##### Mark that we have found the answer #####
        $foundAnswer = "true";

        ##### Since we are only looking for an exact string match just break (We will introduce the concept of rank later) #####
        last;
      }
    }

    ##### We found the document but couldnt find a match for the query #####
    if( $foundAnswer eq "false" ) { print ("Sorry couldn't find anything."); }

  }  

my @expandendCategories = getRelatedSubjects($string);

my @relatedDocuments = getRelatedDocuments(@expandendCategories);

#say "EXPANDED: ";
#print( join("\n", @expandendCategories));


}

#  Method that will query Wikipedia and give back related document
sub getDocumet {

    ##### Loop through the words (Right now only one but will add more subjects later) #####
    for my $word (@words){

        ##### Get the entry from query #####
        my $entry = $wiki->search($word);

        ##### Some entrys may not be defined in our loop so we take that into account #####
        if(defined $entry) { return($entry->fulltext()); }
        
        ##### If its not defined just continue on #####
        else { next; }
    }

    ##### If we cant find anything just return nothing #####
    return "";
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query 
sub createLikelyAnswers{

    my $query = $_[0];

    ##### If we cant find anything just return nothing #####
    my $subject = getSubjectModifier($query);

    ##### If we cant find anything just return nothing #####
    my $queryModifier = getQueryModifier($query);
    
    ##### If we cant find anything just return nothing #####
    my $queryType = getQueryType($query);

    ##### If we cant find anything just return nothing #####
    my @queryList = ();

    ##### If we cant find anything just return nothing #####
    my @conjugations = ();

    ##### If we cant find anything just return nothing #####
    if ( $queryModifier =~ /is|was|where|are/ ) {

        push(@conjugations, "is");
        push(@conjugations, "was");
        push(@conjugations, "were");
        push(@conjugations, "are");
    }

    ##### If we cant find anything just return nothing #####
    my @variations = getVariations(getQuerySubject($subject));

    ##### If we cant find anything just return nothing #####
    my $remainingSentence = "";
      if($subject =~ /[A-Z][a-z]+,?\s[A-Z][a-z]+\s(.*)/) {
        $remainingSentence = $1;
    }

    ##### If we cant find anything just return nothing #####
    for my $conjugation (@conjugations){

        ##### If we cant find anything just return nothing #####
        for my $variation (@variations) {
            push(@queryList, $variation." ".$conjugation." ".$remainingSentence);
        }
    }

    return @queryList;
}

sub getRelatedSubjects{

  my $query = $_[0];

    ##### If we cant find anything just return nothing #####
  my $subject = getSubjectModifier($query);

  my @entry = $wiki->search($subject)->related();

  return @entry;

}










