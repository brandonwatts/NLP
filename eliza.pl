#! usr/bin/perl

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 1
# 2/6/17

######## SUMMARY #########

# This program attempts to recreate the famous ELIZA program. ELIZA was a chatbot
# which used basic "find and replace" mechanism for forming its responses. ELIZA can be
# terminated by typing nothing at all or typing "quit".

########## EXAMPLE CONVERSATION #########

# ELIZA: Hello I am Eliza, a trained psychotherapist. What is your name?
# USER: I am Brandon
# ELIZA: Hello Brandon. Lets get started. What's been bugging you lately?
# USER: I dont know
# ELIZA: What does that suggest to you?
# USER: I am very tired
# ELIZA: Did you come to me because you are very tired?
# USER: no
# ELIZA: Are you sure?
# USER: can you help me
# ELIZA: You want me to be able to help you?
# USER: are you alive
# ELIZA: Why are you interested in whether or not I am alive?
# USER: i feel sick
# ELIZA: Brandon, Do you often feel sick?

######### ALGORITHIMS ########

# Algorithims are decribed in detail below but the idea is that 
# input is read an then stripped of all special characters. Then the following steps are taken.
#
#   1) Search the input looking for a "keyword"
#   2) If we find a keyword we randomly pick an appropriate sentence from bank 
#   3) If we do not find the "keyword" we just output generic response
#   4) When we have a sentence we find the "modifier" (basically everything after keyword)
#   5) We inject modifier in sentence
#   6) We correct the grammar, then output sentence

########## REFERENCES #########

# "Regular Expressions Cheat Sheet" - https://www.cheatography.com/davechild/cheat-sheets/regular-expressions/
# "ELIZA" - https://en.wikipedia.org/wiki/ELIZA
# "A Conversation With ELIZA, The Electronic Therapist" - http://thoughtcatalog.com/oliver-miller/2012/08/a-conversation-with-eliza/ - Helped form alot of the keywords and responses.

use warnings;
use feature qw(say switch);

# This is the bank of keywords along with reponses. I chose some of these word due to a few reasons:
# 1. They are easy to respond to
# 2. They are specific enough to show im listening, yet generic enough to fit a wide range of questions
# 3. Some were used by other ELIZA programs (References Included)
# 4. I liked them
%keywordsWithResponses = (
    "CAN YOU" => [
        "<N>, Do you believe that I can <Q>",
        "Would like me to be able to <Q>",
        "You want me to be able to <Q>"
    ],
    "CAN I",
    => [ "<N>, It seems like you don't want to <Q>", "Do you want to be able to <Q>" ],
    "YOU ARE" => [
        "What makes you think I am <Q>",
        "Perhaps you would like to be <Q>",
        "Do you sometimes wish you were <Q>"
    ],
    "YOU'RE" => [
        "What makes you think I am <Q>",
        "Perhaps you would like to be <Q>",
        "Do you sometimes wish you were <Q>, <N>"
    ],
    "I DON'T" => [
        "Don't you really <Q>",
        "Why don't you <Q>",
        "<N>, Do you wish to be able to <Q>",
        "Does that trouble you?"
    ],
    "I FEEL" => [
        "Tell me more about such feelings.",
        "<N>, Do you often feel <Q>",
        "Do you enjoy feeling <Q>"
    ],
    "WHY DON'T YOU" => [
        "Do you really believe I don't <Q>",
        "Perhaps in good time I will <S>",
        "Do you want me to <Q>"
    ],
    "WHY CAN'T I" =>
      [ "Do you think you should be able to <Q>", "Why can't you <Q>" ],
    "ARE YOU" => [
        "Why are you interested in whether or not I am <Q>",
        "Would you prefer if I were not <Q>",
    ],
    "I CAN'T" => [
        "<N>, How do you know you can't <Q>",
        "Have you tried?",
        "Perhaps you can now <Q>"
    ],
    "I AM" => [
        "Did you come to me because you are <Q>",
        "How long have you been <Q>",
        "Do you believe it is normal to be <Q>",
        "Do you enjoy being <Q>"
    ],
    "I'M" => [
        "Did you come to me because you are <Q>",
        "How long have you been <Q>",
        "Do you believe it is normal to be <Q>",
        "Do you enjoy being <Q>"
    ],
    "YOU" => [
        "<N>, We were discussing you, not me.",
        "You're not really talking about me, are you?"
    ],
    "I WANT" => [
        "What would it mean to you if you got <Q>",
        "Why do you want <Q>",
        "Suppose you got <Q>",
        "What if you never got <Q>",
        "I sometimes also want <S>"
    ],
    "WHAT" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "HOW" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "WHO" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "WHERE" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "WHEN" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "WHY" => [
        "Why do you ask?",
        "Does that question interest you?",
        "What answer would please you the most?",
        "What do you think?",
        "Are such questions on your mind often?",
        "What is it that you really want to know?",
        "Have you asked anyone else?",
        "Have you asked such questions before?",
        "What else comes to mind when you ask that?"
    ],
    "CAUSE" => [
        "Is that the real reason?",
        "Don't any other reasons come to mind?",
        "Does that reason explain anything else?",
        "What other reasons might there be?"
    ],
    "SORRY" => [
        "<N>, Apologies are not necessary.",
        "What feelings do you have when you apologise?",
    ],
    "HELLO" => ["How are you today.. What would you like to discuss?"],
    "HI"    => ["How are you today.. What would you like to discuss?"],
    "MAYBE" => [
        "You don't seem quite certain.",
        "Can't you be more positive?",
        "You aren't sure?",
        "Don't you know?"
    ],
    "NO" => [
        "<N>, Are you saying no just to be negative?",
        "You are being a bit negative.",
        "Why not?", "Are you sure?",
        "Why no?"
    ],
    "YOUR" =>
      [ "Why are you concerned about my <Q>", "What about your own <Q>" ],
    "ALWAYS" => [
        "Can you think of a specific example?",
        "When?",
        "What are you thinking of?",
        "Really, always?"
    ],
    "THINK" => [
        "<N>, Do you really think so?",
        "But you are not sure you <Q>",
        "Do you doubt you <Q>"
    ],
    "ALIKE" => [
        "In what way?",
        "What resemblence do you see?",
        "What does the similarity suggest to you?",
        "What other connections do you see?",
        "Could there really be some connection?",
        "How?",
    ],
    "YES"    => [ "Are you Sure?", "I see.", "I understand." ],
    "FRIEND" => [
        "Do your friends worry you?",
        "Do your friends pick on you?",
        "Perhaps your love for friends worries you."
    ],
    "NO KEY FOUND" => [
        "I didn't quite understand, can you say that another way?",
        "What does that suggest to you?",
        "I see.",
        "I'm not sure I understand you fully.",
        "That is quite interesting."
    ]
);

# Bank of incorrect conjugations to correct versions, respectively
my %secondaryConjugationList = (
    "me am"   => "I am",
    "am me"   => "am I",
    "me can"  => "I can",
    "can me"  => "can I",
    "me have" => "I have",
    "me will" => "I will",
    "will me" => "will I"
);

# Bank of conjugations to know eliza should form response to the user
# For example if the user says "me", ELIZA should respond with "you"
%primaryConjugationList = (
    "are"      => "am",
    "am"       => "are",
    "were"     => "was",
    "was"      => "were",
    "I"        => "you",
    "me"       => "you",
    "you"      => "me",
    "my"       => "your",
    "your"     => "my",
    "mine"     => "your's",
    "your's"   => "mine",
    "I'm"      => "you're",
    "you're"   => "I'm",
    "I've"     => "you've",
    "you've"   => "I've",
    "I'll"     => "you'll",
    "you'll"   => "I'll",
    "myself"   => "yourself",
    "yourself" => "myself"
);


##########      This is the program logic       ##########       

$name = ""; 

say "Hello I am Eliza, a trained psychotherapist. What is your name?";
$input = <STDIN>;      
chomp($input);
if ( $input =~ /([A-Z][a-z]+)\b/ ) {  # Regex to grab first uppercase word that does not start the sentence
    say "Hello $1. Lets get started. What's been bugging you lately?";
    $name = $1;
}
else {  # Assume they entered gibberish
    say "I dont quite understand, I'll just call you Bob. What's been bugging you lately?";
    $name = "Bob";
  }

while(<STDIN>){
  last if ($_ =~ /^\s*$|quit/); # Exit the program if they type "quit" or just hit enter.
  $string = $_; # Grab the input
  $string = stripString($string); # Strip the input of any special characters that may mess with Eliza
  $string = FindQuestion($string); # Find the best question to respond with.
  $string = correctTense($string); # Make sure that question is grammatically sound
  say $string;
}


#  Method to strip a string of all its special characters so eliza can filter out gibberish. (or attempt to)
#
#  @param 0_[]  This contains the input string.
#  return       The string stripped of all special charaters.
sub stripString {
  $string = $_[0];
  $string =~ s/[#\-%&\$*+()]//g; # Substitute all the special characters for nothing 
  chomp($string); 
  return $string;
}

#  Method to check if a string has a <Q> symbol or a <S> symbol which
#  I took to mean Question and statement respectively. If it has either is these symbols, I replace
#  it with the modifier to demonstrate listening to the patient. 
#
#  @param 0_[]  This contains the input string.
#  @param 1_[]  contains the response waiting for modifier
#  @parm  2_[]  contains the keyword found so we dont have to search for it again
#  return       The completed sentence waiting to recieve conjugation.
sub formQuestion {
  $string = $_[0];
  $response = $_[1];
  $keyword = $_[2];
  if($response =~ m/<Q>/){   # If it was a question
      $modifier = findModifier($string,$keyword);
      $modifier = conjugate($modifier); 
      $response =~ s/<Q>/$modifier/; # We change out that symbol for the modifier.
      $response =~ s/<N>/$name/; # We input thier name
      $response = $response."?"; # We put a question mark
      return $response;
  }
  elsif($string =~ m/<S>/) {  # If it was a Statement
      $modifier = findModifier($string,$keyword);
      $modifier = conjugate($modifier);
      $response =~ s/<S>/$modifier/; # We change out the symbol for the modifier.
      $response =~ s/<N>/$name/; # We input thier name
      $response = $response."."; # We put a period
      return $response;
  }
  else {  # Just a generic response so no need to find modifier
    $response =~ s/<N>/$name/; # We input thier name
    return $response;
  }
}

#  Method to find the modifier of a question/statement. We use the term modifier
#  here lightly to mean anything matched after the keyword.  
#
#  @param 0_[]  This contains the input string.
#  @param 1_[]  contains the phrase found in FindQuestion function
#  return       The "modifier" of the keyword.
sub findModifier {
  $string = $_[0];
  $phrase = $_[1];
  $string =~ /$phrase /i; # Regex to find the keyword in the string
  return "$'"; # Grab everything after that keyword
}

#  Method to Find the question based on the specific keywords it spots. Each keyword will have multiple responses
#  so we are just randomizing the choosing process for that as well.
#
#  @param 0_[]  This contains the input string.
#  return       The response. This is either a defualt or a customizeable one handled by the formQuestion function.
sub FindQuestion {
  $string = $_[0];
  $max_responses = 5; # Hold the maximum number of generic responses
  foreach my $key (keys %keywordsWithResponses) {  # Loop through the dictionary
    if ($string =~ m/\b$key\b/i){ # Try to find a keyword
      my $number_of_questions = @{$keywordsWithResponses{$key}}; # Find out how many possible questions we can ask from that keyword
      my $random_response_index = int(rand($number_of_questions)); # Pick from one of our bank of responses at random.
      $response = formQuestion($string,$keywordsWithResponses{$key}[$random_response_index],$key); # being to form our response
      return $response;
    }
  }
  return  $keywordsWithResponses{"NO KEY FOUND"}[int(rand($max_responses))]; # There was no keyword so we do not recognize the sentence
}


#  Method to correct conjuagtion so that Eliza can ask the questions in the correct person
#  using the second conjugation list. We use this so Eliza will output proper pronous
#  acoording the the conjugation rules found in primaryConjugationList.
#
#  @param 0_[]  This contains a string which may or may not have incorrect conjugations.
#  return       The properly conjugated string.
sub conjugate {
  $string = $_[0];
  for my $word (keys %primaryConjugationList) {  # Loop through the conjugation list
     $string =~ s/\b$word\b/$primaryConjugationList{$word}/g; # change all the conjations in our response
    }   
    return $string;
}

#  Method to correct the tense of an input using the second conjugation list. We use this so
#  Eliza will output proper english acoording the the conjugation rules.
#
#  @param 0_[]  This contains a string which may or may not have incorrect conjugations.
#  return       The properly conjugated string.
sub correctTense {
  $string = $_[0];
  for my $phrase (keys %secondaryConjugationList) { # Loop through the second conjugation list
    $string =~ s/\b$phrase\b/$secondaryConjugationList{$phrase}/g; # change all the conjations in our response
  }
    return $string;
}