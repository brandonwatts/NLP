#! usr/bin/perl

use warnings;
#use strict;
use Switch;
use Data::Dumper;
use WWW::Wikipedia;
use Data::CosineSimilarity;
use Sort::Hash::Values;
use feature qw(say);

my $wiki = WWW::Wikipedia->new();
my $rankedNGrams;
my @documents;
my @FeatureVectorLabelingScheme;
my %documentToFeatureVector; 

say "This is a QA system by Brandon Watts. It will try to answer questions that start with Who, What, When or Where. Enter \"exit\" to leave the program.";

while(<STDIN>){
  last if ($_ =~ /quit/); 
  my $string = $_; 
  
  say "Obtaining Query...";
  @words  = ("school", "bus");

  say "Creating Documents...";
  @documents = createDocuments(@words);
    
    createFeatureVector("What color is a bus");
    #@featureVectorForString = @{createFeatureVectorForString("What color is a bus?")};
     #print ("Feature vector for query: ". join(" ",@featureVectorForString));
     #print join ("_______________________\n", @documents);
    rankDocuments();
}

sub createFeatureVector {
    my $query = $_[0];

    my @wordsInQuery =  $query =~ /\S+/g;
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


sub expandQuery{
    my $sentences = $_[0];
    $sentences =~ s/[,\."'\)\(;]//g;
    my @words =  $sentences =~ /\S+/g;
    @categories = ();

    for my $word (@words){
        my $entry = $wiki->search($sentences);

        if(defined $entry) {
            push(@categories,$entry->related());
        }
        else {
            next;
        }
    }
    return @categories;
}


    sub parseWikiData{
        my $data = $_[0];
        $data =~ s/<ref>|<\/ref>|<ref//g;
        $data =~ s/(\{)?(\{)?(\s*?.*?)*?\}\}//g;
        $data =~ s/name="?.*"?>//g;
        $data =~ s/<!--.*-->//g;
        #$data =~ s/\ba\b|\ban\b|\band\b|\bare\b|\bas\b|\bat\b|\bbe\b|\bby\b|\bfor\b|\bfrom\b|\bhas\b|\bhe\b|\bin\b|\bis\b|\bit\b|\bit's\b|\bof\b|\bon\b|\bthat\b|\bthe\b|\bto\b|\bwas\b|\bwere\b|\bwill\b|\bwith\b//gi; 
        $data =~ s/\s+/ /g; 
        $data =~ s/[,\."'\)\(;]//g;
        return $data;
    }

sub createDocuments {
    @Queries = @_;

    @documents = ();

    for my $query (@Queries){
         my $entry = $wiki->search($query);

        if(defined $entry) {
            push(@documents,parseWikiData($entry->text()));
        }
        else {
            next;
        }
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




