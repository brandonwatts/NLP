#! usr/bin/perl

use warnings;
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
# Assignment 6
# 4/24/17

######### Changes for PA6 #########

# Enhancement 1 for Query Reformulation: The addition of "Variations"

  # It was seen upon inspecting a Wiki document that a given person's name is not used throughout the text. For example "George Washigton" is only 
  # stated a couple times whereas "George" or "Washington" may appear many times. In addition to "George Washington" I am also searching
  # for these partial matches as well.

# Enhancement 2 for Query Reformulation: The addition of Tense phrases.

  # In addition to Variations I added to the ability for the query to change tense phrases. For example if you search "When is Geroge Washington's birthday?"
  # my system converts that "is" into its different conjugations ("was","where","are","were") and searches those as well.

# Enhancement 1 for Answer Composition: The addition of "Filtering"

  # I found that my answer system was just stupidly picking the first sentence that matched the regex. To aliveiate this, the system picks 
  # all sentences that matches the regex and filters out the ones that dont match the expected answer type. For example if we were searching for
  # "When was George Washington born?" the expected answer type would be a Date and so we could eliminate everythign that was not a date.

# Enhancement 2 for Answer Composition: The addition of the "Backoff Model"

  # I noticed that my QA system was a bit slow because of the time that was required to get the fulltext and parse it. To alleviate this,
  # the system first checks if the answer is in the head of the file and only if we cant find it there do we move on the the fulltext. 

# Calulation of confidence scores
  
  # Confidence scores were calculated by multiplying a small fraction (.99) by 1 to slowly decrease the confidence the more iterations the
  # algorithim runs. This is becase for each iteration a new backoff model is introduced which impacts our confidence score.

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

#   1) The query is first parsed to remove puctutation and unknown symbols
#   2) The expected answer to the question is then obtained
#   3) Using a NER, the subject and modifier are both obtained from the query
#   4) The subject is then used to query Wikipedia and obtain its document
#   5) "Searching" through the document involves trying to first find the direct regex match for the query and then slowly backing
#       off as the answers query moves farther away from the direct answer
#   6) Once an answer is found we assign a confidence score to it, if we cannot find an answe we print "Answer not found"

########## REFERENCES #########
# WWW::Wikipedia - http://search.cpan.org/~bricas/WWW-Wikipedia-2.04/lib/WWW/Wikipedia.pm
# File::Slurp - http://search.cpan.org/~uri/File-Slurp-9999.19/lib/File/Slurp.pm
# Data::Dumeper - http://search.cpan.org/~smueller/Data-Dumper-2.161/Dumper.pm
# Lingua::EN::NamedEntity - http://search.cpan.org/dist/Lingua-EN-NamedEntity/NamedEntity.pm

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

  append_file( $logFile, "\n-------------------- BEGIN TRANSACTION --------------------\n") ;

  ##### Get input from the user #####
  my $string = parseQuery($_); 

  ##### Get everything after the query modifier #####
  my $subject = getSubjectModifier($string);

  ##### Obtain our Expected Answer #####
  my $expectedAnswer = getExpectedAnswer($string);
  
  ##### Get the subject and the query type #####
  my ($querySubject, $queryType) = getQuerySubject($string);

  ##### Get the document #####
  $document = parseWikiData(getDocumet($querySubject));

  ##### Obtain all the possible variations of the answer #####
  my @las = createLikelyAnswers($string);
  
  ##### The answer we will be returning #####
  my $returnAnswer;

  append_file( $logFile, "\nWe are looking for document relating to: $querySubject \t\t From Query: $string\n") ;

  ##### Boolean value to test if we have found the answer #####
  my $foundAnswer = "false";

  ##### Confidence Score of our answer #####
  my $CONFIDENCE_SCORE = 1;

  ##### The user must have input the Query incorrectly #####
  if( $document eq "" ) {
    say "Answer could not be obtained with the provided query";
  }

  else{

    append_file( $logFile, "\nGenerated Search Querys: \n\n") ;

    ##### Loop through our likely answers an attempt to find a direct string match from our document #####
    for my $las (@las){

      ##### Every time we make our loop we are getting farthen away from a direct string match so our confidence score decreases #####
      $CONFIDENCE_SCORE = $CONFIDENCE_SCORE * .99;

      append_file( $logFile, "$las\n");

      ##### If the first part of the document contains our answer #####
      if ($document =~ /$las([^\.]*)/i) {
        $foundAnswer = "true";
        $returnAnswer = "$las$1";
        last;
      }
    }

    ##### We were not able to find the answer in the top part so we need to search the whole text now #####
    if( $foundAnswer eq "false" ) { 
        
      $document = parseFullWiki(getFullText($querySubject));

      ##### Becasue the answer may appear multiple times we need to store all answers in an array #####
      my @possibleAnswers;

      for my $las (@las){   
        push(@possibleAnswers, $document =~ /($las[^\.]*)/ig);
      }
      
      for my $possibleAnswers (@possibleAnswers) {

        ##### Every time we make our loop we are getting farthen away from a direct string match so our confidence score decreases #####
        $CONFIDENCE_SCORE = $CONFIDENCE_SCORE * .99;

        ##### If it was a "When" Question #####
        if($expectedAnswer eq "DATE"){

          ##### If the possible answer has a number in it, return it. Otherwise keep looking #####
          if($possibleAnswers =~ m/.*\d.*/){

            $foundAnswer = "true";
            $returnAnswer = "$possibleAnswers";
            last;
          }

          else{ next; }
        }

        else {
          $foundAnswer = "true";
          $returnAnswer = $possibleAnswers;
          last;
        } 
      }
    }
  }

  ##### We still could not find the answer #####
  if( $foundAnswer eq "false" ) { 
    say "Answer not found.";
    append_file( $logFile, "\nWe Could not find an Answer.\n") ;
    append_file( $logFile, "\nConfidence Score: 0.0\n") ;
  }
  else{
    say ("$returnAnswer.");
    append_file( $logFile, "\nWe Choose: $returnAnswer.\n") ;
    append_file( $logFile, "\nConfidence Score: $CONFIDENCE_SCORE\n") ;

  }

  append_file( $logFile, "\n-------------------- END TRANSACTION --------------------\n") ;
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