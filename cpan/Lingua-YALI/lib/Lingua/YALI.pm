package Lingua::YALI;
# ABSTRACT: YALI - Yet Another Language Identifier.

use strict;
use warnings;
use Carp;

# VERSION

=head1 SYNOPSIS

The YALI package is collection of modules and tools for language identification.

=head2 Modules

=over    

=item * L<Lingua::YALI::Examples|Lingua::YALI::Examples> - contains examples.

=item * L<Lingua::YALI::LanguageIdentifier|Lingua::YALI::LanguageIdentifier> - is module for language identification capable of identifying 122 languages.

=item * L<Lingua::YALI::Builder|Lingua::YALI::Builder> - is module for training custom language models.

=item * L<Lingua::YALI::Identifier|Lingua::YALI::Identifier> - allows to use own models for identification.

=back

=head2 Tools

=over    

=item * L<yali-language-identifier|Lingua::YALI::yali-language-identifier> - tool for language identification with pretrained models

=item * L<yali-builder|Lingua::YALI::yali-builder> - tool for building custom language models.

=item * L<yali-identifier|Lingua::YALI::yali-identifier> - tool for language identification with custom language models.

=back

=cut

=head1 WHY TO USE YALI

=over

=item * Contains pretrained models for identifying 122 languages.

=item * Allows to create own models, trained on texts from specific domain, which outperforms the pretrained ones.

=item * It is based on published paper L<http://ufal.mff.cuni.cz/~majlis/yali/>.

=back

=head1 COMPARISON WITH OTHERS

=over

=item * L<Lingua::Lid|Lingua::Lid> can recognize 45 languages and returns only the most probable result without any weight.

=item * L<Lingua::Ident|Lingua::Ident> requires training files, so it is similar to L<Lingua::YALI::LanguageIdentifier|Lingua::YALI::LanguageIdentifier>, 
but it does not provide any options for constructing models.

=item * L<Lingua::Identify|Lingua::Identify> can recognize 33 languages but it does not allows you to use different models. 

=back

=cut

# TODO: refactor - remove bzcat
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
    _print_result($result, $format, $languages);
}

sub _identify
{
    my ($identifier, $file, $format, $languages) = @_;
    my $result = $identifier->identify_file($file);
    _print_result($result, $format, $languages);
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
        $line = join("\t", map { $res{$_} } @$languages);
    } else {
        croak("Unsupported format $format");
    }
    
    print $line . "\n";
}

1;
