use Test::More tests => 6;
use Test::Exception;
use File::Basename;
use Carp;
use strict;
use warnings;


use Lingua::YALI::LanguageIdentifier;


BEGIN { use_ok('Lingua::YALI::LanguageIdentifier') };
my $identifier = Lingua::YALI::LanguageIdentifier->new();

ok($identifier->add_language("ces", "eng") == 2, "adding two languages");

open(my $fh_ces, "<:bytes", dirname(__FILE__) . '/ces01.txt') or croak $!;
my $ces_string = "";
while ( <$fh_ces> ) {
    $ces_string .= $_;
}
my $result_ces = $identifier->identify_string($ces_string);
is($result_ces->[0]->[0], 'ces', 'Czech must be detected');
is($result_ces->[1]->[0], 'eng', 'Czech must be detected');

open(my $fh_eng, "<:bytes", dirname(__FILE__) . '/eng01.txt') or croak $!;
my $eng_string = "";
while ( <$fh_eng> ) {
    $eng_string .= $_;
}
my $result_eng = $identifier->identify_string($eng_string);
is($result_eng->[0]->[0], 'eng', 'English must be detected');
is($result_eng->[1]->[0], 'ces', 'English must be detected');
