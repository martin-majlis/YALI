package Lingua::YALI::LanguageIdentifier;
use strict;
use warnings;


# ABSTRACT: Returns information about languages.

=encoding utf8
=cut

use File::ShareDir;
use File::Glob;
use Carp;
use Moose;

extends 'Lingua::YALI::Identifier';



has '_languages' => (is => 'rw', isa => 'ArrayRef');

has '_language_model' => (is => 'rw', isa => 'HashRef');


=method add_language(@languages)

Registres new languages @languages for identification.

=head4 Returns number of newly added languages.

=cut
sub add_language
{
    my ($self, @languages) = @_;

    # lazy loading
    if ( ! defined($self->_languages) ) {
        $self->get_available_languages();
    }

    my $added_languages = 0;
    for my $lang (@languages) {
        if ( ! defined($self->{_language_model}->{$lang}) ) {
            croak("Unknown language $lang");
        }
        $added_languages += $self->add_class($lang, $self->{_language_model}->{$lang});
    }

    return $added_languages;
}

=method remove_language(@languages)

Remove languages @languages for identification.

=head4 Returns number of removed languages.

=cut
sub remove_language
{
    my ($self, @languages) = @_;

    # lazy loading
    if ( ! defined($self->_languages) ) {
        $self->get_available_languages();
    }

    my $added_languages = 0;
    for my $lang (@languages) {
        if ( ! defined($self->{_language_model}->{$lang}) ) {
            croak("Unknown language $lang");
        }
        $added_languages += $self->remove_class($lang);
    }

    return $added_languages;
}

=method get_languages

Returns registered languages.

=head4 Returns \@languages

=cut
sub get_languages
{
    my $self = shift;
    return $self->get_classes();
}

=method get_available_languages

Returns all available languages that could be identified.

=head4 Returns \@all_languages

=cut

sub get_available_languages
{
    my $self = shift;
    # Get a module's shared files directory

    if ( ! defined($self->_languages) ) {

        my $dir = File::ShareDir::dist_dir('Lingua-YALI');
#        print STDERR "\n\n" . $dir . "\n\n";

        my @languages = ();
        #$self->_language_model = ();

        for my $file (File::Glob::bsd_glob($dir . "/*.yali.gz")) {
            my $language = $file;
            $language =~ s/\Q$dir\E.//;
            $language =~ s/.yali.gz//;
            push(@languages, $language);

            $self->{_language_model}->{$language} = $file;

        }
        $self->_languages(\@languages);
#        print STDERR join("\t", @languages), "\n";
    }

    return $self->_languages;
}

1;
