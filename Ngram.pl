#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 2
# 2/16/17

######## SUMMARY #########

# This program attempts to produce a number of sentences given a "corpus". The corupus are text files fed into the program. The program can handle a huge number of files.
# The program then creates an "N-Gram Mapping" based on the second parameter provided to the program. This parameter is used to store more information about the sentences,
# which makes the output more comprehensible, but it also lessens uniqueness.

########## EXAMPLE USE CASES #########

# $ perl Ngram.pl 3 4 First-Offensive.txt The-Battle-for-Saipan.txt 

#1. Page 17 by general merrill b.

#2. While we guadalcanal and the 1st parachute battalion landed near noon in three waves , 395 men in all , there were approximately 100 , 000 reising sub machine guns hadn t caught up with demand and the stamped out m3 grease gun had not yet established its reputation.

#3. See paragraph indicated to me that he was firmly convinced that we were in the midst of their planned offensive.

#4. I crawled of fanaticism characterizing the japanese , meanwhile , were falling back to a final defensive line north of garapan.

#####

# $ perl Ngram.pl 4 2 The-Battle-for-Saipan.txt 

#1. Kelley , usa was sounded.

#2. Smith sidebar the the norm.

######### ALGORITHIMS ########

# Algorithims are decribed in detail below but the idea is that create a hash of all
# the times a specific word appears in the given corups. We then create a hash of the specified N-Gram size mapped to the next word.
# Dividing the Ngram Count by the frequency count gives us the relative frequency. We use this to generate our sentences. We start by normalizing our relative 
# frequencies and then randomly picking one according to the higher probabliity. Once we have our choice we do this again for the next word unless we hit an <end> tag.
#
#   1) Read in a specific text file using the File::Slurp Module.
#   2) Start by striping that file of all tabs, and extra spaces.
#   3) We then create our frequency table by running through the file and keeping a talley of how many times we see a specific token.
#   4) After that, We break our file up into sentences by spliting on the punctuation
#   5) We can use these sentences to generate our NGram Model so we dont cross over sentence boundaries.
#   6) Creating the NgramMapping is done by specifing a "slice size" (just the N-gram size), we use this to grab every X words and map them to the word in front of it.
#   7) A talley of how many times we see a specfic mapping is stored in %rawfrequencyTableCount which completes our N-Gram
#   8) To generate a sentence we find the beginning word phrase by randomly picking a key with the token "<start>" in it.
#   9) With that token we can find every asscoiation to it, normalize thier frequencies, rank thier probabiliteis, then pick a random number which will choose one based on said probablilities.
#   10) We then repeat the process with the next token until we reach the end of the sentence
#   11) We then format the sentence and return it.
#   12) We repeat this process a given number of times specified by the user.

########## REFERENCES #########

# "Regular Expressions Cheat Sheet" - https://www.cheatography.com/davechild/cheat-sheets/regular-expressions/
# "N-grams" - https://en.wikipedia.org/wiki/N-gram

use warnings;
use feature qw(say switch);
use File::Slurp;
use File::Basename;

my %frequencyTables;
my %NgramMapping;
my %rawfrequencyTableCount;
my %rawfrequencyTable;
my $NUMBEROFSENTENCES = $ARGV[1];
my $NGRAMSIZE;

if($ARGV[0] <= 1) {
    say "Must have an Ngram Size of at least 2."
}else {

    $NGRAMSIZE = $ARGV[0]-1; # We minus one because "bigram" actually means key size of 1.

    for(my $i=2; $i < @ARGV; $i++) {
        my $text = read_file($ARGV[$i]);
        process($text);
    }

    my $name = basename($0);

    print "\nThis program generates random sentences based on an Ngram model. Written by Brandon Watts.\n";
    say "\nCommand line settings: $name $NGRAMSIZE $NUMBEROFSENTENCES\n";
    say generateSentences($NUMBEROFSENTENCES);
}

# This is the firt method called which then sets up and delegates the creation of the frequency table and the creation of the Ngram Mapping.
#
#  @param $_[0]  This is the file in its entirety.
sub process {

    my $file = $_[0];
    $file =~ s/\s+|_/ /g; # Delete all of the Tabs and remove extra Spaces.

    createFrequencyTable($file);

    my @inputSentences = $file =~ /\s+[^.!?]*[.!?]/g; # Break the file into individual sentences splitting on the punctuation.
    createNgramMapping($NGRAMSIZE, \@inputSentences); # Creates the NGram Mapping of the specified siza using the sentences from the file.
}

#  Method that will create our N-gram Mapping 
#
#  @param $_[0]  Will hold the specified "Slice Size" the Ngram Size - 1 (basically tells us how many words are in a key, so for example a bigram(size 2) would have a key size of 1)
#  @param $_[1]  Will contain an array of all sentences in a given file.
sub createNgramMapping {

    my $sliceSize  = $_[0];
    my @sentences = @{$_[1]};

    for my $sentence (@sentences)
    {
        my @sentenceTokens = $sentence =~ /[\w']+|[.,!?;]/g; # Split the sentence into indivdual tokens.

        unshift( @sentenceTokens, "<START>" ); # Add the <START> token to the front.
        push( @sentenceTokens, "<END>" ); # add the the <END> token to the end.

        foreach my $i (0.. $#sentenceTokens ) {
            
            my $startingPoint; # Used to know what token we are currently at.
            my @tempArray = (); # Array to store all the keys of that current token.

            $startingPoint = $i - $sliceSize < 0 ? -1 : $i - $sliceSize; # Used to check if a key can be made (to stop someone from wanting an N-Gram bigger than the entire sentence)

                if ($startingPoint == -1) { next; }  # N-gram is bigger than availible words.
                else {
                    for my $j($startingPoint...$i-1) { # Grab the number of words before that given token specified by the N-gram Size.
                        push (@tempArray, $sentenceTokens[$j]);
                    }
                }

        my $key = join(" ", @tempArray ); # Build our token

        insertNgramMapping( $key, $sentenceTokens[$i]); #insert that mapping into our Hash

        }
    }
}

#  Method that will create our Frequency Table
#
#  @param $_[0]  Will hold the file in its entirety.
sub createFrequencyTable {

    my $file = $_[0];
    my @inputSentences = $file =~ /\s+[^.!?]*[.!?]/g; # Break the file into individual sentences splitting on the punctuation.
    
    for my $sentence (@inputSentences) {
            
        my @tokens = $sentence =~ /[\w']+|[.,!?;]/g; # break the file into tokens

        unshift( @tokens, "<START>" ); # Add the <START> token to the front.
        push( @tokens, "<END>" ); # Add the <END> token to the front.

        foreach my $word (@tokens) { $frequencyTable{lc($word)}++; } # count the number of times that a given token appears.
    }
}

#  Method to generate a sentence based off our N-gram models 
#
#  return  The completed sentence when a punctuation token is finally reached.
sub generateSentence { 

    my $currentWord = findStartingWordPhrase(); # Randomly generate a starting phrase to give us place to begin.
    my $sentence = substr(findStartingWordPhrase(),8); # Delete the token "<start>" so it is not displayed.
  
    do{

        my %tempHash = (); # Used to hold the normalized frequency of a hash of possible next words.
        my $normalizationFactor = 0; # Used to normalize the data set.
        my $currentPositionOnNumberLine = 0; # Used to create our number line.
        my @numberLine = (); # Array of next words stored by increasing normalized frequency.
        my @numberLineValues =(); # Array of the normalized frequencies stored by increasing normalized frequency.

        ########## Loop through the possible keys and generate a normalization factor ########## 
        for my $value ( keys %{$rawfrequencyTable{"$currentWord"}}) {
            $normalizationFactor += $rawfrequencyTable{"$currentWord"}{$value};
        }

        ########## Loop through possible keys and use the normalization factor to figure out where it belongs on number line ##########
        for my $value ( keys %{$rawfrequencyTable{"$currentWord"}}) {
            $tempHash{$value} = $rawfrequencyTable{"$currentWord"}{$value}/$normalizationFactor + $currentPositionOnNumberLine;
            $currentPositionOnNumberLine += $rawfrequencyTable{"$currentWord"}{$value}/$normalizationFactor;
        }

        push (@numberLineValues, 0); # Start by adding Zero on the number line

        ########## Loops through the tokens and pushes them on to the number line in increasing fashion. #########
        foreach my $token (sort { $tempHash{$a} <=> $tempHash{$b} } keys %tempHash) {
            push(@numberLine,$token);
            push (@numberLineValues, $tempHash{$token})
        }

        push (@numberLineValues, 2); # Add 2 to the end of the number line because the number line values are all < 0.
        
        my $randNumber = rand(); # Generate a random number between 0 and 1.
        my $nextWord;

        ########## Loop through the number line values (Excluding 0 and 2) and figure out where our random number falls on the number line to pick our next word##########
        foreach my $i (1...$#numberLineValues-1) { 

            if($randNumber < $numberLineValues[$i] && $randNumber > $numberLineValues[$i-1]) {

                $nextWord = $numberLine[$i-1]; # Get the value of the next word that waas selected.
                $sentence = $sentence." ".$nextWord; # Append it to our sentence.

                if($currentWord =~ /\s/) { $nextWord = removeFirstWord($currentWord)." ".$nextWord; } # It is not a bigram and thus needs part of the current word to form our next word (exluding the first word of the current word).
                
                last; # No need to keep going through loop
            }
        }

        $currentWord = $nextWord; # Start it all again with next Word  

    } until ($currentWord =~ /[!.?]/); # Keep going until we reach a punctuation.

    return formatted($sentence); # Format the sentance then return it
}

#  Helper method that will find a starting point to start generating our sentences.
#
#  return  Starting token
sub findStartingWordPhrase {

    my @startingWordPhraseChoices = (); # Array to hold our possible choices for a starting token

    ########## Loop through the Ngram mapping and if a token contains "<start>" we add it to the startingWordPhasechoices Array. #########
    foreach my $key ( keys %NgramMapping ) { 
        if ($key =~ /<start>/) {
            push(@startingWordPhraseChoices,$key);
        }
    }

    ########## Pick a random choice abd return it as our starting word phrase. ##########
    my $randomChoice = int rand($#startingWordPhraseChoices+1);
    return $startingWordPhraseChoices[$randomChoice];
}

#  Helper method that will call the generateSentence method a number of times specified by the User and print it on the screen.
sub generateSentences {
    my $numberOfSentencesToGenerate = $_[0];
    foreach my $i(0... $numberOfSentencesToGenerate-1) {
        my $startingWord = generateSentence(findStartingWordPhrase(),"");
        my $index = $i + 1;
        print ("\n$index. $startingWord\n");
    }
}

#  Helper method that will format a string before printing it to the user by capitalizing the first letter and removing unneccesary spacing.
#
#  @param $_[0]  The unnformatted string
#  return  The formatted String
sub formatted {

    my $unformattedString = $_[0];

    ##########  Trim the string #########
    $unformattedString =~ s/^\s+|\s+$//g;

    ########## Remove Spacing inbetween token and punctuation ##########
    $unformattedString =~ s/([a-z])\s([.!?])/$1$2/g;

    ########## Capitalize the first letter and return formatted string #########
    $unformattedString = ucfirst($unformattedString); 
    return $unformattedString;
}

#  Helper method that will remove the first word of a string
#
#  @param $_[0]  The string 
#  return  The same string with the first word removed.
sub removeFirstWord() {
    my $string = $_[0];
    if($string =~ /^([\s]*[\S]+\s).*$/) { $string =~ s/$1//;} # Regex to remove the first word.
    return $string;
}

#  Helper method that will allow for easy entry into the N-Gram mapping.
#
#  @param $_[0]  A key
#  @param $_[0]  A value
sub insertNgramMapping {

    ########## Start by lowercasing the key and the value ##########
    my $key             = lc($_[0]);
    my $value           = lc($_[1]);

    $NgramMapping{$key} = $value; # Insert into our Ngram Mapping

    $rawfrequencyTableCount{$key."|".$value}++; # Increase its frequency by 1.

    $rawfrequencyTable{$key}{$value} = $rawfrequencyTableCount{$key."|".$value}/$frequencyTable{$value}; # Generate the rawfrequency value and store it in a double hash.
}

#################### Methods Used for debugging ####################

sub printRawFrequencyTable {
    say "---------------------- Raw Frequency Table ----------------------------";

    for my $key ( keys %rawfrequencyTable ) {
        
        print "$key: ";

        for my $value ( keys %{ $rawfrequencyTable{$key} } ) {
            print "$value=$rawfrequencyTable{$key}{$value} ";
        }

        print "\n";
    }
}

sub printFrequecyTable {

    say "---------------------- Frequency Table ----------------------------";

    foreach my $key ( keys %frequencyTable ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $frequencyTable{$key});
    }
}

sub printNgramMapping {

    say "---------------------- NGram Mapping ----------------------------";

    foreach my $key ( keys %NgramMapping ) {    # Loop through the dictionary
        printf("KEY: %-25s VALUE: %-25s\n", $key, $NgramMapping{$key});
    }
}
