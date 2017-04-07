#! usr/bin/perl

use warnings;
#use strict;
use Switch;
use Data::Dumper;
use File::Slurp;
use WWW::Wikipedia;
use Data::CosineSimilarity;
use Sort::Hash::Values;
use feature qw(say);
use QueryManipulation;
use WikiParser;

my $wiki = WWW::Wikipedia->new();
my $rankedNGrams;
my @documents;
my @FeatureVectorLabelingScheme;
my %documentToFeatureVector;
my @words; 

say "This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter \"exit\" to leave the program.";

while(<STDIN>){
  chomp;
  last if ($_ =~ /quit/); 
  my $string = $_; 
  my @las = createLikelyAnswers($string);
  my $subject = getSubjectModifier($string);
  my $queryModifier = getQueryModifier($string);
  my $queryType = getQueryType($string);
  @words  = ("$subject");
  my $document = parseWikiData(getDocumet());
  print $document;
 
 my $foundAnswer = "false";
  for my $las (@las){
     if ($document =~ /$las ([^\.]*)/i)
    {
        print ("Results: $1.\n");
        $foundAnswer = "true";
        last;
    }
  }
  if($foundAnswer eq "false"){
    print ("Sorry couldn't find anything.");
  }
}

sub getDocumet {
    for my $word (@words){
        my $entry = $wiki->search($word);

        if(defined $entry) {
            return($entry->fulltext());
        }
        else {
            next;
        }
    }
    return "";
}



sub createLikelyAnswers{
    my $query = $_[0];
    my $subject = getSubjectModifier($query);
    my $queryModifier = getQueryModifier($query);
    my $queryType = getQueryType($query);
    my @queryList = ();
    my @conjugations = ();

    if($queryModifier =~ /is|was|where|are/){
        push(@conjugations, "is");
        push(@conjugations, "was");
        push(@conjugations, "were");
        push(@conjugations, "are");
    }
    my @variations = getVariations(getQuerySubject($subject));

    my $remainingSentence = "";
      if($subject =~ /[A-Z][a-z]+,?\s[A-Z][a-z]+\s(.*)/) {
        $remainingSentence = $1;
    }


    for my $conjugation (@conjugations){
        for my $variation (@variations) {
            push(@queryList, $variation." ".$conjugation." ".$remainingSentence);
        }
    }

    return @queryList;
}