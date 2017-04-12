package DocumentManipulation;

######### INFORMATION ########

# Brandon Watts
# CMSC 416
# Assignment 5 - Wiki Parser
# 4/10/17

######## SUMMARY #########

# This program is a rudimentary Question and answering system using Wikipedia as a backend. It attempts to answer four basic 
# types of questions: Who, What, When or Where by means of query rewriting and direct regex matching.

######### ALGORITHIMS ########

#   There were really no major alogorithims used in this iteration of the QA system but I will decribe the method by which I 
#   turned a query into a response.
#
#   1) 
#   2) 
#   3) 
#   4) 

########## REFERENCES #########
# Exporter - http://perldoc.perl.org/Exporter.html
# Switch - http://perldoc.perl.org/5.8.8/Switch.html

use warnings;
use Switch;
use Data::CosineSimilarity;
use Sort::Hash::Values;
use Exporter;
use WikiParser;

our @ISA= qw( Exporter );
our @EXPORT = qw( getRelatedDocuments );

my $wiki = WWW::Wikipedia->new();

sub createUnigrams {
    $wikiResponse = $_[0];

    my %unigrams; 

    my @responseWords =  $wikiResponse =~ /\S+/g;

    foreach my $word (@responseWords){ $unigrams{$word}++; }

    return %unigrams 
}
    
sub createBigrams {
    $wikiResponse = $_[0];
        
    my %bigrams; 
        
    my @responseWords =  $wikiResponse =~ /\S+/g;
        
    foreach my $i ( 1 .. $#responseWords ) { $bigrams{$responseWords[$i-1]." ".$responseWords[$i]}++; }
}

sub createTrigrams {
    $wikiResponse = $_[0];
        
    my %trigrams; 

    my @responseWords =  $wikiResponse =~ /\S+/g;

    foreach my $i (2 .. $#responseWords){

        $trigrams{$responseWords[$i-2]." ".$responseWords[$i-1]." ".$responseWords[$i]}++;
    }
}

sub rankNGrams {

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

sub getRelatedDocuments {

    @Queries = @_;

    @documents = ();

    for my $query ( @Queries ) {
        
        my $entry = $wiki->search($query);

        if(defined $entry) { push(@documents,parseWikiData($entry->text())); }
        
        else { next; }
    }

    return @documents;
}

sub rankDocuments {

    ##### Get variable from the Data::CosineSimilarity Module #####
    $cs = Data::CosineSimilarity-> new;

    ##### Will hold the documents #####
    my %documentHash;

    ##### Loop over all the documents #####
    for my $j (0..$#documents) {

        ##### Feature Vector for the particular document #####
        my @vector = ();

        ##### Loop over all the features and check if its in our document #####
        for my $word (@FeatureVectorLabelingScheme) {

            ##### If the feature is in our document, mark it with a one #####
            if ($documents[$j] =~ /\b$word\b/) {
                push(@vector, "1");
            }

            ##### If the feature is not in our document, mark it with a zero #####
            else {
                push(@vector, "0");
            }
        }
          
        ##### Loop over our feature vector and create document Hash #####
        for my $i (0 .. $#vector) {
            $documentHash{'document'.$j}{$FeatureVectorLabelingScheme[$i]} = $vector[$i];
        }
    }

    ##### Add the documents to the cosine similarity variable #####
    for my $keys (keys %documentHash) {
        $documentHashRef = \%documentHash;
        $cs->add($keys => $documentHashRef->{$keys});
    }
    

    my $r = $cs->similarity( 'document0', 'document1' );
    my $cosine = $r->cosine;

    print "CosineSimilarity: $cosine";
}


sub createFeatureVector {
    my $query = $_[0];

    my $documentsAsString = join(" ", @documents);
    my @wordsInDocuments =  $documentsAsString =~ /\S+/g;

    my %featureTracker;

    for my $word (@wordsInQuery) {
        $featureTracker{$word} = 1
    }

    for my $word (@wordsInDocuments) {
        $featureTracker{$word} = 1
    }

    %featureVectorsForDocuments = %featureTracker;

   for my $key (keys %featureVectorsForDocuments) {
        push(@FeatureVectorLabelingScheme,$key);
    }
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
1;