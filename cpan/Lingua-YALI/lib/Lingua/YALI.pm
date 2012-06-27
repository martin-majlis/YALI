use strict;
use warnings;
package Lingua::YALI;
# ABSTRACT: YALI - Yet Another Language Identifier.

=head1 SYNOPSIS

The YALI package contains several modules:

=over    

=item * L<Lingua::YALI::Examples|Lingua::YALI::Examples> - contains examples.

=item * L<Lingua::YALI::LanguageIdentifier|Lingua::YALI::LanguageIdentifier> - is module for language identification capable of identifying 122 languages.

=item * L<Lingua::YALI::Identifier|Lingua::YALI::Identifier> - allows to use own models for identification.

=item * It is based on published L<http://ufal.mff.cuni.cz/~majlis/yali/>.

=back

=cut

=head1 WHY TO USE YALI

=over

=item * Contains pretrained models for identifying 122 languages.

=item * Allows to create own models, trained on texts from specific domain, which outperforms the pretrained ones.

=back

=head1 COMPARISON WITH OTHERS

=over

=item * L<Lingua::Lid|Lingua::Lid> can recognize 45 languages and returns only the most probable result without any weight.

=item * L<Lingua::Ident|Lingua::Ident> requires training files, so it is similar to L<Lingua::YALI::LanguageIdentifier|Lingua::YALI::LanguageIdentifier>, 
but it does not provide any options for constructing models.

=item * L<Lingua::Identify|Lingua::Identify> can recognize 33 languages but it does not allows you to use different models. 

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

sub _identify_fh
{
    my ($identifier, $fh, $format, $languages) = @_;
    my $result = $identifier->identify_handle($fh);
    _print_result($result, $format);
}

sub identify
{
    my ($identifier, $file, $format, $languages) = @_;
    my $result = $identifier->identify_file($file);
    _print_result($result, $format);
}


sub _print_result
{
    my ($result, $format, $languages) = @_;
    my $line = "";
    if ( $format eq "single" ) {
        if ( scalar @$result > 0 ) {
            $line = $result->[0]->[0];
        }
    } elsif ( $format eq "all" ) {
        $line = join("\t", map { $_->[0] } @{$result});
    } elsif ( $format eq "all_p" ) {
        $line = join("\t", map { $_->[0].":".$_->[1] } @{$result});
    } elsif ( $format eq "tabbed" ) {
        my %res = ();
        map { $res{$_->[0]} = $_->[1] } @{$result};
        $line = join("\t", map { my $prob = 0; if ( $res{$_} ) { $prob = $res{$_}; }; $prob; } @$languages);
    }
    
    print $line . "\n";
}

1;
