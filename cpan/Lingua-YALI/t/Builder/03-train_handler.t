use Test::More tests => 4;
use Test::Exception;
use File::Basename;


BEGIN { use_ok('Lingua::YALI::Builder') };
my $builder = Lingua::YALI::Builder->new(ngrams=>[2,3,4]);

open(my $fh_a, "<:bytes", dirname(__FILE__) . "/../Identifier/aaa01.txt") or croak $!;
is($builder->train_handler($fh_a), 1, "training on input");
close($fh_a);

is($builder->train_handler(undef), undef, "undef file handler");

dies_ok { $builder->train_handler("aaaaaaaaaaaa") } "not file handler";

#TODO: zjistit, jak kontrolovat filehandle otevreny pro zapis, kdyz z neho chci cist.
#my $file = dirname(__FILE__) . "/write.txt";
#open(my $fh_w, ">:bytes", $file) or croak $!;
#dies_ok { $builder->train_handler($fh_w) } "training on file handle opened for writing";
#close($fh_w);
