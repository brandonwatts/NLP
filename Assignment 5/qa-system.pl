#! usr/bin/perl

use warnings;
use Switch;
use Data::Dumper;
use WWW::Wikipedia;
use feature qw(say);

my $wiki = WWW::Wikipedia->new();
 

say "This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter \"exit\" to leave the program.";

while(<STDIN>){
  last if ($_ =~ /quit/); 
  $string = $_; 
  @transformedQueries =  rewriteQuery($string);
  $expectedAnswer = getExpectedAnswer($string);
  
  #foreach my $query (@transformedQueries) {
      #  print("QUERY: $query");
      queryWiki($query);
  #}
  printBigrams();
  printTrigrams();
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

sub rewriteQuery{
    my $query = $_[0];
    my $queryType = getQueryType($query);
    transformQuery($query,$queryType);
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

sub transformQuery{
    my $query = $_[0];
    my $queryType = $_[1];
    my @returnQueries = ();
    
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
            return @returnQueries;
        }
    }

    $query =~ s/\b$queryModifier\b//g;
    my @queryWords =  $query =~ /\S+/g;

    foreach my $i (-1...$#queryWords) {
        my $newQuery =  join(" ",arrayInsertAfterPosition(\@queryWords,$i,$queryModifier));
        push(@returnQueries, $newQuery);
    }
    return @returnQueries;
}

    sub arrayInsertAfterPosition
    {
        my ($inArray, $inPosition, $inElement) = @_;
        my @res         = ();
        my @after       = ();
        my $arrayLength = int @{$inArray};

        if ($inPosition < 0) { @after = @{$inArray}; }
            else {
            if ($inPosition >= $arrayLength)    { $inPosition = $arrayLength - 1; }
            if ($inPosition < $arrayLength - 1) { @after = @{$inArray}[($inPosition+1)..($arrayLength-1)]; }
        }

        push (@res, @{$inArray}[0..$inPosition],
              $inElement,
              @after);

        return @res;
    }

    sub queryWiki{
        my $query = $_[0];
        my $entry = $wiki->search("Jeff Sessions");
        my $text = $entry->text_basic();
        $text = parseWikiData($text);
        createUnigrams($text);
        createBigrams($text);
        createTrigrams($text);
    }

    sub parseWikiData{
        my $data = $_[0];
        $data =~ s/<ref>|<\/ref>|<ref//g;
        $data =~ s/(\{)?(\{)?(\s*?.*?)*?\}\}//g;
        $data =~ s/name="?.*"?>//g;
        $data =~ s/<!--.*-->//g;
        $data =~ s/\s+/ /g; 
        return $data
    }

    my %unigrams; 
    sub createUnigrams {
        $wikiResponse = $_[0];
        my @responseWords =  $wikiResponse =~ /\S+/g;
        foreach my $word (@responseWords){
            $unigrams{$word}++;
        }
    }
    
    my %bigrams; 
    sub createBigrams {
        $wikiResponse = $_[0];
        my @responseWords =  $wikiResponse =~ /\S+/g;
        foreach my $i (1 .. $#responseWords){
            $bigrams{$responseWords[$i-1]}{$responseWords[$i]}++;
        }
    }

    my %trigrams; 
    sub createTrigrams {
        $wikiResponse = $_[0];
        my @responseWords =  $wikiResponse =~ /\S+/g;
        my @responseWords =  $wikiResponse =~ /\S+/g;
        foreach my $i (2 .. $#responseWords){
            $trigrams{$responseWords[$i-2]." ".$responseWords[$i-1]}{$responseWords[$i]}++;
        }
    }


sub printUnigrams {
    say "---------------------- Unigram Mapping ----------------------------";

    for my $key (keys %bigrams) {
        printf("Word: %-25s Given We Just Saw: %-25s Frequency: %-25s\n", $secKey, $key, $bigrams{$key}{$secKey});
        }
}

sub printBigrams {

    say "---------------------- Bigram Mapping ----------------------------";

        for my $key (keys %bigrams) {
            my $hash = $bigrams{$key};
            for my $secKey (sort { $hash->{$a}<=>$hash->{$b} } keys %$hash) {
                       printf("Word: %-25s Given We Just Saw: %-25s Frequency: %-25s\n", $secKey, $key, $bigrams{$key}{$secKey});
            }
        }
    

}

sub printTrigrams {

    say "---------------------- Trigram Mapping ----------------------------";

   for my $key (keys %trigrams) {
            my $hash = $trigrams{$key};
            for my $secKey (sort { $hash->{$a}<=>$hash->{$b} } keys %$hash) {
                printf("Word: %-25s Given We Just Saw: %-25s Frequency: %-25s\n", $secKey, $key, $trigrams{$key}{$secKey});
            }
        }

}



