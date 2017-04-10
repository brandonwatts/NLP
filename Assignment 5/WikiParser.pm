package WikiParser;
use warnings;
use Switch;
use Exporter;

our @ISA= qw( Exporter );
our @EXPORT = qw( parseWikiData );

#  Method that breaks a query up into likely answers that we can feed into our regex.
#
#  @param $_[0]  The Query
sub parseWikiData{
    my $data = $_[0];
    $data =~ s/<ref>|<\/ref>|<ref//g;
   # $data =~ s/(\{)?(\{)?(\s*?.*?)*?\}\}//g;
    $data =~ s/name="?.*"?>//g;
    $data =~ s/[^a-zA-Z0-9.]/ /g; 
    $data =~ s/\s+/ /g;
    $data =~ s/([A-Z])\.([A-Z])\./$1$2/g;
    return $data;
}

1;