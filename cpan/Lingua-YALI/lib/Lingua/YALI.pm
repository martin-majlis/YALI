use strict;
use warnings;
package Lingua::YALI;
# ABSTRACT: YALI - Yet Another Language Identifier.

=head1 SYNOPSIS

The YALI package contains several modules:

=over    

=item * L<Lingua::YALI::Examples|Lingua::YALI::Examples> - contains examples.

=item * L<Lingua::YALI::LanguageIdentifier|Lingua::YALI::LanguageIdentifier> - is capable of recognizing 122 languages.

=item * L<Lingua::YALI::Identifier|Lingua::YALI::Identifier> - allows to use own models for identification.

=item * L<Lingua::YALI::Builder|Lingua::YALI::Builder> - allows to construct own models for identification.


=back

=cut

sub _open
{
    my ($f) = @_;

    croak("Not found: $f") if !-e $f;

    my $opn;
    my $hdl;
    my $ft = qx(file '$f');

    # file might not recognize some files!
    if ( $f =~ /\.gz$/ || $ft =~ /gzip compressed data/ ) {
        $opn = "zcat $f |";
    }
    elsif ( $f =~ /\.bz2$/ || $ft =~ /bzip2 compressed data/ ) {
        $opn = "bzcat $f |";
    }
    else {
        $opn = "$f";
    }
    open($hdl,"<:bytes", $opn) or croak ("Can't open '$opn': $!");
    binmode $hdl, ":bytes";
    return $hdl;
}
1;
