#! usr/bin/perl

use warnings;
use strict;
use Switch;
use WWW::Wikipedia;
use File::Slurp;
use feature qw(say);
use QueryManipulation;
use WikiParser;

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
#   1) I first rewrot the query into a possible answer form using the subject and the question type 
#   2) From there I parsed the subject out of the Query and used Wikipedia to obtain its document
#   3) If the document cannot be obtained it attempts to search through related documents but has so far been unsuccessful
#   4) "Searching" through the document involves attempting to direct regex match the likely answer

########## REFERENCES #########
# WWW::Wikipedia - http://search.cpan.org/~bricas/WWW-Wikipedia-2.04/lib/WWW/Wikipedia.pm
# File::Slurp - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm

my $wiki = WWW::Wikipedia->new();

##### File that output will be witten to #####
my $logFile = $ARGV[0];

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

  ##### Get the document/s from wikipedia regarding our subjects #####
  $document = parseWikiData(getDocumet(getQuerySubject($subject)));

  ##### Create an array of likey representations of the answers #####
  my @las = createLikelyAnswers($string);


 

  ##### Write log #####
  append_file( $logFile, "\nWe are looking for document relating to: $subject \t\t From Query: $string\n") ;

  ##### Boolean Variable to test if we have found the answer. #####
  my $foundAnswer = "false";

  ##### Document could not be obtained with the provided query #####
  if( $document eq "" ) {
    say "Answer could not be obtained with the provided query";
  }

  ##### We were able to obtain a document from Wiki ##### 
  else{

    my $returnAnswer;
      append_file( $logFile, "\nGenerated Search Querys: \n") ;

    ##### Loop through our likely answers an attempt to find a direct string match from our document #####
    for my $las (@las){

      append_file( $logFile, "$las\n") ;


      ##### If our document contains our answer #####
      if ($document =~ /$las([^\.]*)/i) {
        if ($foundAnswer eq "false") {
            $foundAnswer = "true";
            $returnAnswer = "$las$1";
        }
      }
    }

    ##### We found the document but couldnt find a match for the query #####
   # if( $foundAnswer eq "false" ) { 

    #************** INTRODUCE BACKOFF MODEL NEXT PA ******************#

    #  say "Expanding Search...";

     # ##### Get all the related categories #####
      #my @expandendCategories = getRelatedSubjects($string);

      ##### Get all the documents from those categories #####
      #my @relatedDocuments = getRelatedDocuments(@expandendCategories);

      ##### loop over each document #####
     # for my $document (@relatedDocuments) {
        
        ##### Loop over each likely answer #####
      #  for my $las (@las){

          ##### If our document contains our answer #####
       #   if ($document =~ /$las([^\.]*)/i) {

            ##### print the answer to the console #####
        #    print ("$las$1.\n");

            ##### Mark that we have found the answer #####
         #   $foundAnswer = "true";

            ##### Since we are only looking for an exact string match just break (We will introduce the concept of rank later) #####
          #  last;
          #}
        #}
      #} 

      ##### We still could not find the answer #####
      if( $foundAnswer eq "false" ) { 
              print("Sorry we couldnt find anything.\n");
      } else {
          say ($returnAnswer);
      }


    #append_file( $logFile, "\n****************************** Raw Data: ******************************\n") ;
    #append_file( $logFile, "\n$document\n") ;
    #append_file( $logFile, "\n************************************************************************\n") ;



    append_file( $logFile, "\nWe Choose: $returnAnswer\n") ;

    append_file( $logFile, "\n-------------------- END TRANSACTION --------------------\n") ;

    #}
  }  
     ##### End writing to logfile #####
}

#  Method that will query Wikipedia and give back related document
sub getDocumet {

  my $query = $_[0];
  
  ##### Get the entry from query #####
  my $entry = $wiki->search($query);

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
    my @variations = getVariations(getQuerySubject($subject));
    my @variationsWithMiddleName = ();

    for my $variation (@variations) {
      
      my $firstName;
      my $lastName;

      if ($variation =~ /([A-Z][a-z]+),?\s([A-Z][a-z]+)/) {
        $firstName = $1;
        $lastName = $2;
        if ($document =~ /$firstName\s(\w+)\s$lastName/) {
          push(@variationsWithMiddleName,("$firstName $1 $lastName"));
        }
      }
    }

   push(@variationsWithMiddleName,@variations);


    ##### Get everything after the subject #####
    my $remainingSentence = "";
    if($subject =~ /[A-Z][a-z]+,?\s[A-Z][a-z]+\s(.*)/) {
        $remainingSentence = $1;
    }

    ##### loop over every variation #####
    for my $variation (@variationsWithMiddleName) {

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