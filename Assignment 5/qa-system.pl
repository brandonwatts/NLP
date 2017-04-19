#! usr/bin/perl

use warnings;
#use strict;
use Switch;
use WWW::Wikipedia;
use File::Slurp;
use feature qw(say);
use QueryManipulation;
use WikiParser;
use Data::Dumper;
use Lingua::EN::NamedEntity;
use String::Util 'trim';

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5
# 4/12/17

######## SUMMARY #########

# This program is a rudimentary Question and Answering system using Wikipedia as a backend. It attempts to answer four basic 
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
#   1) I first rewrote the query into a possible answer form using the subject and the question type 
#   2) From there I parsed the subject out of the Query and used Wikipedia to obtain its document
#   3) If the document cannot be obtained it attempts to search through related documents but has so far been unsuccessful
#   4) "Searching" through the document involves attempting to direct regex match the likely answer

########## REFERENCES #########
# WWW::Wikipedia - http://search.cpan.org/~bricas/WWW-Wikipedia-2.04/lib/WWW/Wikipedia.pm
# File::Slurp - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm

my $wiki = WWW::Wikipedia->new();

##### File that output will be witten to #####
my $logFile = $ARGV[0];

##### document obtained my the Wiki Search #####
my $document;

##### A Quick Greeting to the user #####
say "This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter \"exit\" to leave the program.";

while(<STDIN>){
  chomp;

  ##### Quit the program if the user types "exit" #####
  last if ($_ =~ /exit/); 

  ##### Start wrtiing to log file #####
  append_file( $logFile, "\n-------------------- BEGIN TRANSACTION --------------------\n") ;

  ##### Get input from the user #####
  my $string = parseQuery($_); 

  ##### Get the subject from the query #####
  my $subject = getSubjectModifier($string);

  my $expectedAnswer = getExpectedAnswer($string);

  my ($querySubject, $queryType) = getQuerySubject($string);

  ##### Get the document/s from wikipedia regarding our subjects #####
  $document = parseWikiData(getDocumet($querySubject));

  ##### Create an array of likey representations of the answers #####
  my @las = createLikelyAnswers($string);

  ##### Write log #####
  append_file( $logFile, "\nWe are looking for document relating to: $querySubject \t\t From Query: $string\n") ;

  ##### Boolean Variable to test if we have found the answer. #####
  my $foundAnswer = "false";

  ##### Document could not be obtained with the provided query #####
  if( $document eq "" ) {
    say "Answer could not be obtained with the provided query";
  }

  ##### We were able to obtain a document from Wiki ##### 
  else{

    my $returnAnswer;
    
    ##### Print to log file #####
    append_file( $logFile, "\nGenerated Search Querys: \n") ;

    ##### Loop through our likely answers an attempt to find a direct string match from our document #####
    for my $las (@las){

    append_file( $logFile, "$las\n");

      ##### If our document contains our answer #####
      if ($document =~ /$las([^\.]*)/i) {
          $foundAnswer = "true";
          $returnAnswer = "$las$1.";
      }
    }
    if( $foundAnswer eq "false" ) { 
        
        $document = parseFullWiki(getFullText($querySubject));

         append_file( $logFile, $document) ;


          for my $las (@las){

            append_file( $logFile, "$las\n") ;

            if ($document =~ /$las([^\.]*)/i) {

              if($expectedAnswer eq "DATE"){

                if($1 =~ m/.*\d.*/){
                  $foundAnswer = "true";
                  $returnAnswer = "$las$1.";
                  last;
                }
                else{
                  print("$1\n");
                  next;
                }
              }
              else {
                $foundAnswer = "true";
                $returnAnswer = "$las$1.";
              } 
            }
          }
    }
  }
  ##### We still could not find the answer #####
  if( $foundAnswer eq "false" ) { 
    say "Answer not found."
  }
  else{
    say ($returnAnswer);
  }

    append_file( $logFile, "\nWe Choose: $returnAnswer\n") ;

    append_file( $logFile, "\n-------------------- END TRANSACTION --------------------\n") ;

  #}  
     ##### End writing to logfile #####
}

#  Method that will query Wikipedia and give back related document
sub getDocumet {

  my $query = $_[0];
  
  ##### Get the entry from query #####
  my $entry = $wiki->search("$query");

  ##### Some entrys may not be defined so we take that into account #####
  if(defined $entry) { return($entry->text()); }
  else { return ""; }
}

sub getFullText {

  my $query = $_[0];
  
  ##### Get the entry from query #####
  my $entry = $wiki->search("$query");

  ##### Some entrys may not be defined so we take that into account #####
  if(defined $entry) { return($entry->fulltext()); }
  else { return ""; }
}

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query 
sub createLikelyAnswers{

    my $query = $_[0];


    ##### Get the subject #####
    my $subject = getSubjectModifier($query);

    ##### Get the Query Modifier #####
    my $queryModifier = getQueryModifier($query);

    ##### List of all the possible likely answers#####
    my @queryList = ();

    ##### conjugations of our query modifier #####
    my @conjugations = ();

    ##### apply gonjugation rules #####
    if ( $queryModifier =~ /is|was|where|are|were|/ ) {

        push(@conjugations, "is");
        push (@conjugations, "were");
        push(@conjugations, "was");
        push(@conjugations, "were");
        push(@conjugations, "are");
    }

    ##### Grab the different variations of a name #####
    my ($querySubject, $queryType) = getQuerySubject($query);
    my @variations = getVariations($querySubject, $queryType);

    ##### Get everything after the subject #####
    my $remainingSentence = "";
    if($subject =~ /$querySubject\s(.*)/) {
        $remainingSentence = $1;
    }

    ##### loop over every variation #####
    for my $variation (@variations) {

      ##### Loop over every possible conjugation #####
      for my $conjugation (@conjugations){

        ##### Add that answer to a likely answer. #####
        push(@queryList, $variation." ".$conjugation." ".$remainingSentence);
      }
    }

    return @queryList;
}

#  Method that gets all the related subjects to our current subject 
#
#  @param $_[0]  The Query 
sub getRelatedSubjects{

  my $query = $_[0];
  my $subject = getQuerySubject($query);
  my @entry = $wiki->search($subject)->related();
  return @entry;
}

sub getRelatedDocuments {

    my @Queries = @_;

    my @documents = ();

    for my $query ( @Queries ) {
        
        my $entry = $wiki->search($query);

        if(defined $entry) { push(@documents,parseWikiData($entry->text())); }
        
        else { next; }
    }

    return @documents;
}