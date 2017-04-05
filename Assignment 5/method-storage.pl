
sub getType{

    my $word = $_[0];
    my $query = $_[0];
    my @categories;
    my $entry = $wiki->search($word);

    if(defined $entry) {
      @categories = $entry->categories();
    }
    else {
        return "UNDEFINED";
    }

    my $returnType = "Object";
    for my $category (@categories){
        if($category =~ m/Cities/){
            $returnType = "City";
        }
        elsif($category =~ m/people/){
            $returnType = "Person";
        }
    }

    return $returnType;
}

sub tileNGrams {
    my @orderedKeys;
    for my $key (sort_values { $b <=> $a } %rankedNGrams) {
        push(@orderedKeys, $key);
    }
    print("\n_____________BEFORE CHANGES__________\n");
    print join("\n", @orderedKeys);

    for my $i (0 .. $#orderedKeys) {
        my $startingKey = $orderedKeys[$i];
         for my $j ($i+1..$#orderedKeys) {
            if($orderedKeys[$j] =~ /\b$startingKey\b\s(.*)/){
                    print ("Replacing @orderedKeys[$i] with @orderedKeys[$i] $1\n");
                   $orderedKeys[$i] = $orderedKeys[$i]." ".$1;
            }
        }
    }
    print("_____________AFTER CHANGES__________\n");
    print join("\n", @orderedKeys);

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
            $bigrams{$responseWords[$i-1]." ".$responseWords[$i]}++;
        }
    }

    my %trigrams; 
    sub createTrigrams {
        $wikiResponse = $_[0];
        my @responseWords =  $wikiResponse =~ /\S+/g;
        my @responseWords =  $wikiResponse =~ /\S+/g;
        foreach my $i (2 .. $#responseWords){
            $trigrams{$responseWords[$i-2]." ".$responseWords[$i-1]." ".$responseWords[$i]}++;
        }
    }


sub printUnigrams {
    say "---------------------- Unigram Mapping ----------------------------";

    for my $key (sort_values { $b <=> $a } %unigrams) {
        printf("Word: %-25s Given We Just Saw: %-25s\n", $key, $unigrams{$key});
        }
}

sub printBigrams {

    say "---------------------- Bigram Mapping ----------------------------";

        for my $key (sort_values { $b <=> $a } %bigrams) {
        printf("Word: %-25s Given We Just Saw: %-25s\n", $key, $bigrams{$key});
        }
    

}

sub printTrigrams {

    say "---------------------- Trigram Mapping ----------------------------";

     for my $key (sort_values { $b <=> $a } %trigrams) {
        printf("Word: %-25s Given We Just Saw: %-25s\n", $key, $trigrams{$key});
        }
}

sub rankList {
    my $totalSpots = 0;
    for my $key (sort_values { $b <=> $a } %unigrams) {
        if ($totalSpots < 10)
        {
            $rankedNGrams{$key} = $unigrams{$key};
            $totalSpots++;
        }
    }

    $totalSpots = 0;
        for my $key (sort_values { $b <=> $a } %bigrams) {
        if ($totalSpots < 10)
        {
            $rankedNGrams{$key} = $bigrams{$key};
            $totalSpots++;
        }
    }

    $totalSpots = 0;
       for my $key (sort_values { $b <=> $a } %trigrams) {
        if ($totalSpots < 10)
        {
            $rankedNGrams{$key} = $trigrams{$key};
           $totalSpots++;
        }
    }

    for my $key (keys %rankedNGrams) {
        my $type = getType($key);
        if($type ne "UNDEFINED")
        {
            $rankedNGrams{$key} = $rankedNGrams{$key} + 10;
        }
    }

   # for my $key (sort_values { $b <=> $a } %rankedNGrams) {
    #    printf("Word: %-35s Frequency: %-25s Type:%-25s\n", $key, $rankedNGrams{$key}, getType($key));
    #}
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


    sub queryWiki{
        my $query = $_[0];
        my $entry = $wiki->search("Albert Einstein");
        my $text = $entry->text_basic();
        @categories = $entry->categories();
        $text = parseWikiData($text);
        createUnigrams($text);
        createBigrams($text);
        createTrigrams($text);
    }