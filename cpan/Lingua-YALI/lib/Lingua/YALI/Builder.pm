package Lingua::YALI::Builder;

use strict;
use warnings;
use Moose;
use Carp;
use Lingua::YALI;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw(uniq);

# ABSTRACT: Returns information about languages.

subtype 'PositiveInt',
      as 'Int',
      where { $_ > 0 },
      message { "The number you provided, $_, was not a positive number" };
      

has 'ngrams' => ( is => 'ro', isa => 'ArrayRef[PositiveInt]', required => 1 );
has '_max_ngram' => ( is => 'rw', isa => 'Int' );
has '_dict' => ( is => 'rw', isa => 'HashRef' );

=method BUILD

Bla bla

=cut
sub BUILD
{
    my $self = shift;
    my @unique = uniq( @{$self->{ngrams}} );
    my @sorted = sort { $a <=> $b } @unique;
    $self->{ngrams} = \@sorted;
    $self->{_max_ngram} = $sorted[$#sorted];
}


=method get_ngrams

Bla bla

=cut
sub get_ngrams
{
    my $self = shift;
    return $self->ngrams;
}

=method get_max_ngram

Bla bla

=cut
sub get_max_ngram
{
    my $self = shift;
    return $self->{_max_ngram};
}

=method train_file($file)

Bla bla

=cut
sub train_file
{
    my ( $self, $file ) = @_;
    if ( ! defined($file) ) {
        return;
    }

    my $fh = Lingua::YALI::_open($file);

    return $self->train_handler($fh);
}

=method train_string($string)

Bla bla

=cut
sub train_string
{
    my ( $self, $string ) = @_;
    
    if ( ! defined($string) ) {
        return;
    }
    
    open(my $fh, "<", \$string) or croak $!;

    my $result = $self->train_handler($fh);

    close($fh);

    return $result;
}

=method train_handler($fh)

Bla bla

=cut
sub train_handler
{
    my ($self, $fh, $verbose) = @_;

#    print STDERR "\nX\n" . (ref $fh) . "\nX\n";

    if ( ! defined($fh) ) {
        return;
    } elsif ( ref $fh ne "GLOB" ) {
        croak("Expected file handler but " . (ref $fh) . " was used.");
    }
    
    my %actRes = ();

#    my $padding = $self->{_padding};
    my @ngrams = @{$self->ngrams};
    my $padding = "";
    my $subsub = "";
    my $sub = "";    

    while ( <$fh> ) {
        chomp;
        s/ +/ /g;
        s/^ +//g;
        s/ +$//g;
        if ( ! $_ ) {
            next;
        }

        $_ = $padding . $_ . $padding;

        {
            use bytes;
            for my $i (0 .. bytes::length($_) - $self->{_max_ngram}) {
                $sub = substr($_, $i, $self->{_max_ngram});
                for my $j (@ngrams) {
                    $subsub = bytes::substr($sub, 0, $j);
#                   if ( $subsub =~ /[[:digit:][:punct:]]/ ) {
#                       next;
#                   }

                    $self->{_dict}->{$j}{$subsub}++;
                    $self->{_dict}->{$j}{___total___}++;
                }
            }
        }
    }

    return 1;
}

=method store($file, $ngram, $lines)

Bla bla

=cut
sub store
{
    my ($self, $file, $ngram, $lines) = @_;

    if ( ! defined($self->{_dict}->{$ngram}) ) {
        croak("$ngram-grams were not counted.");
    }

    open(my $fhModel, ">:gzip:bytes", $file) or die $!;
    
    print $fhModel $ngram . "\n";

    {
        no warnings;

        my $i = 0;
        for my $k (sort { $self->{_dict}->{$ngram}{$b} <=> $self->{_dict}->{$ngram}{$a} } keys %{$self->{_dict}->{$ngram}}) {
            print $fhModel "$k\t$self->{_dict}->{$ngram}{$k}\n";
            if ( ++$i > $lines ) {
                last;
            }
        }
    }

    close($fhModel);
}
1;
