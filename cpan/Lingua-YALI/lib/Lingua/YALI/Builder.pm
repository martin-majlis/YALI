package Lingua::YALI::Builder;
# ABSTRACT: Constructs model for document identification.
# VERSION

use strict;
use warnings;
use Moose;
use Carp;
use Lingua::YALI;
use Moose::Util::TypeConstraints;
use List::MoreUtils qw(uniq);
use POSIX;


=head1 SYNOPSIS

This modul creates models for L<Lingua::YALI::Identifier|Lingua::YALI::Identifier>.

Creating bigram and trigram models from a string.

    use Lingua::YALI::Builder;
    my $builder = Lingua::YALI::Builder->new(ngrams=>[2, 3]);
    $builder->train_string("aaaaa aaaa aaa aaa aaa aaaaa aa");
    $builder->store("model_a.2_4.gz", 2, 4);
    $builder->store("model_a.2_all.gz", 2);
    $builder->store("model_a.3_all.gz", 3);
    $builder->store("model_a.4_all.gz", 4); // croaks

More examples is presented in L<Lingua::YALI::Examples|Lingua::YALI::Examples>.

=cut

subtype 'PositiveInt',
      as 'Int',
      where { $_ > 0 },
      message { "The number you provided, $_, was not a positive number" };


has 'ngrams' => ( is => 'ro', isa => 'ArrayRef[PositiveInt]', required => 1 );
has '_max_ngram' => ( is => 'rw', isa => 'Int' );
has '_dict' => ( is => 'rw', isa => 'HashRef' );

=method BUILD

    BUILD()

Constructs C<Builder>. It also removes duplicities from C<ngrams>.

    my $builder = Lingua::YALI::Builder->new(ngrams=>[2, 3, 4]);

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

    my \@ngrams = $builder->get_ngrams()

Returns all n-grams that will be used during training.
 
    my $builder = Lingua::YALI::Builder->new(ngrams=>[2, 3, 4, 2, 3]);
    my $ngrams = $builder->get_ngrams();
    print join(", ", @$ngras) . "\n";
    // prints out 2, 3, 4
    
=cut

sub get_ngrams
{
    my $self = shift;
    return $self->ngrams;
}

=method get_max_ngram

    my $max_ngram = $builder->get_max_ngram()

Returns the highest n-gram size that will be used during training.

    my $builder = Lingua::YALI::Builder->new(ngrams=>[2, 3, 4]);
    print $builder->get_max_ngram() . "\n";
    // prints out 4

=cut

sub get_max_ngram
{
    my $self = shift;
    return $self->{_max_ngram};
}

=method train_file

    my $used_bytes = $builder->train_file($file)

Trains classifier on file C<$file> and returns the amount of bytes used for trainig. 

=over

=item * It returns undef if C<$file> is undef.

=item * It croaks if the file C<$file> does not exist or is not readable.

=item * It returns the amount of bytes used for trainig otherwise.

=back

For more details look at method L</train_handle>.

=cut

sub train_file
{
    my ( $self, $file ) = @_;
    if ( ! defined($file) ) {
        return;
    }

    my $fh = Lingua::YALI::_open($file);

    return $self->train_handle($fh);
}

=method train_string

    my $used_bytes = $builder->train_string($string)

Trains classifier on string C<$string> and returns the amount of bytes used for trainig. 

=over

=item * It returns undef if C<$string> is undef.

=item * It returns the amount of bytes used for trainig otherwise.

=back

For more details look at method L</train_handle>.

=cut

sub train_string
{
    my ( $self, $string ) = @_;

    if ( ! defined($string) ) {
        return;
    }

    open(my $fh, "<", \$string) or croak $!;

    my $result = $self->train_handle($fh);

    close($fh);

    return $result;
}

=method train_handle

    my $used_bytes = $builder->train_handle($fh)

Trains classifier on file handle C<$fh> and returns the amount of bytes used for trainig. 

=over

=item * It returns undef if C<$fh> is undef.

=item * It croaks if the C<$fh> is not file handle.

=item * It returns the amount of bytes used for trainig otherwise.

=back

=cut
sub train_handle
{
    my ($self, $fh) = @_;

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

    my $total_length = 0;

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

            my $act_length = bytes::length($_);
            $total_length += $act_length;
                    
            for my $i (0 .. $act_length - $self->{_max_ngram}) {
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

    return $total_length;
}

=method store

    my $stored_count = $builder->store($file, $ngram, $count)

Stores trained model with at most C<$count> C<$ngram>-grams to file C<$file>. 
If count is not specified all C<$ngram>-grams are stored.

=over

=item * It croaks if incorrect parameters are passed.

=item * It returns the amount of n-grams stored.

=back

=cut

sub store
{
    my ($self, $file, $ngram, $count) = @_;

    if ( ! defined($file) ) {
        croak("parametr file has to be specified");
    }

#    if ( -f $file && ! -w $file ) {
#        croak("file $file has to be writeable");
#    }

    if ( ! defined($ngram) ) {
        croak("parametr ngram has to be specified");
    }

    if ( ! defined($self->{_dict}->{$ngram}) ) {
        croak("$ngram-grams were not counted.");
    }

    if ( ! defined($count) ) {
        $count = POSIX::INT_MAX;
    }

    if ( $count < 1 ) {
        croak("At least one n-gram has to be saved. Count was set to: $count");
    }

    open(my $fhModel, ">:gzip:bytes", $file) or croak($!);

    print $fhModel $ngram . "\n";

    my $i = 0;
        
    {
        no warnings;

        for my $k (sort { $self->{_dict}->{$ngram}{$b} <=> $self->{_dict}->{$ngram}{$a} } keys %{$self->{_dict}->{$ngram}}) {
            print $fhModel "$k\t$self->{_dict}->{$ngram}{$k}\n";
            if ( ++$i > $count ) {
                last;
            }
        }
    }

    close($fhModel);
    
    return ($i - 1);
}

=head1 SEE ALSO

=over

=item * Identifier for these models is L<Lingua::YALI::Identifier|Lingua::YALI::Identifier>.

=item * Source codes are available at L<https://github.com/martin-majlis/YALI>.

=back

=cut

1;
