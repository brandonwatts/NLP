package WikiParser;
use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );

# these are exported by default.
our @EXPORT = qw( parseWikiData );

sub parseWikiData{
    my $data = $_[0];
    $data =~ s/<ref>|<\/ref>|<ref//g;
    #$data =~ s/(\{)?(\{)?(\s*?.*?)*?\}\}//g;
    $data =~ s/name="?.*"?>//g;
   # $data =~ s/\(.*\)//g;
    #$data =~ s/<!--.*-->//g;
    #$data =~ s/\s+/ /g; 
    #$data =~ s/[,"'\)\(;]//g;
    return $data;
}

1;