#!/usr/bin/env perl
#  ../scripts/detect-ngram.pl --size=1000 --ngram=3 --dict=model.limited/1048576/ --lang-file=bow.list.1048576 --lang-count=30 --in=sets/1048576/1000/30/3.test.counts.tsv.gz --freq-norm=1
use strict;
use warnings;

$| = 1;
binmode(STDIN, ":bytes");
binmode(STDOUT, ":bytes");
binmode(STDERR, ":bytes");

use File::Temp qw/tempdir tempfile/;
use Getopt::Long qw/GetOptionsFromArray/;
use File::Path;
use File::Basename;
use File::Glob ':glob';

my ($ngram, $size, $dictDir, $langFile, $langCount, $freqNorm);

my %dictionary = ();
my %frequency = ();
my $dictionarySize = 0;
my @dictionaryKeys = ();
my $padding = "";

my %opts = (
  "ngram" => \$ngram,
  "dict" => \$dictDir,
  "lang-file" => \$langFile,
  "freq-norm" => \$freqNorm,
);

my @optionspec = (
  "ngram=i",
  "dict=s",
  "lang-file=s",
  "freq-norm=i"
);

GetOptions(\%opts, @optionspec) or exit 1;

# ngram
if ( ! defined($ngram) ) {
	print STDERR "N-gram size must be specified! (--ngram)\n";
	help();
}

# dictionary
if ( ! defined($dictDir) ) {
	print STDERR "Path to dictionary must be specified! (--dict)\n";
	help();
}

if ( ! -d $dictDir ) {
	print STDERR "Dictionary dir [$dictDir] doesn\'t exist.\n";
	help();
}

# languages
if ( ! defined($langFile) ) {
	print STDERR "Path to language file must be specified! (--lang-file)\n";
	help();
}

if ( ! -f $langFile ) {
	print STDERR "Language file [$langFile] doesn\'t exist.\n";
	help();
}

# size
if ( ! defined($freqNorm) ) {
	print STDERR "Frequency normalization must be specified! (--freq-norm)\n";
	help();
}

my $beginTime = time();

# load languages
print STDERR "Loading languages\n";
my @allLanguages = loadLanguageList($langFile);

$langCount = $#allLanguages + 1;
print STDERR "Language count: $langCount\n";

# load dictionary
print STDERR "Loading dictionary\n";
my %dictionaryFiles = loadDictionaryFiles($dictDir, $ngram);

# check whether all files exist
my $dictionaryError = 0;
for my $lang (@allLanguages) {
	print STDERR "$lang: $dictionaryFiles{$lang}\n";
	if ( ! defined($dictionaryFiles{$lang}) ) {
		print STDERR "Dictionary file for language $lang is missing!\n";
		$dictionaryError = 1;
	}
}
if ( $dictionaryError ) {
	die "One or more dictionaries are missing!\n";
}



my @usedLanguages = ();


# get new part of languages
my @newLanguages = @allLanguages[$0 .. ($langCount -1)];

print STDERR "Building model - BEGIN: ", time(), "\n";
# add new words into dictionary
for my $lang (@newLanguages) {
	extendDictionary($lang, $dictionaryFiles{$lang});
}
print STDERR "Actual dictionary size: $dictionarySize\n";
print STDERR "Building model - END: ", time(), "\n";

push(@usedLanguages, @newLanguages);

print STDERR "Predicting - BEGIN: ", time(), "\n";

my @languages = @usedLanguages;
my $lineNum = 1;
while ( <STDIN> ) {
	chomp;
	my $inFile = $_;
	processFile($inFile);
	if ( $lineNum % 100 == 0 ) {
		print STDERR "*";
		if ( $lineNum % 1000 == 0 ) {
			print STDERR "\t$lineNum\n";
		}
	}
	$lineNum++;
}
print STDERR "\n";

print STDERR "Predicting - END: ", time(), "\n";

my $endTime = time();
print STDERR "Total time: ", $endTime - $beginTime, "\n";

exit;

sub processFile
{
	my $inFile = shift;

#	print STDERR "Processing $inFile\n";

	my %actRes = ();

	my $fh = my_open($inFile);

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
			for my $i (0 .. bytes::length($_) - $ngram) {
				my $w = substr($_, $i, $ngram);

				if ( defined($frequency{$w}) ) {
					for my $lang (keys %{$frequency{$w}}) {
#						print STDERR "$w - $lang - $frequency{$w}{$lang}\n";
						$actRes{$lang} += $frequency{$w}{$lang};
	#					print STDERR "Lang: $lang - $actRes{$lang}\n";
					}
				}
			}			
		}

	}

	my $resLang = (sort { $actRes{$b} <=> $actRes{$a} } keys %actRes)[0];
	if ( ! $resLang ) {
		$resLang = "";
	}
	print "$inFile\t$resLang\n";
#	print STDERR "\t$resLang\n";

}



sub loadLanguageList
{
	my $file = shift;
	
	open(my $fh, "<", $file);

	my @languages = ();

	while ( <$fh> ) {
		chomp;
		s/\.txt//g;
		push(@languages, $_);
	}

	close($fh);

	return @languages;
}

sub loadDictionaryFiles
{
	my $dir = shift;
	my $ngram = shift;

	print STDERR "Reading dictionaries from directory $dir for n-gram $ngram\n";

	return map { /.*\/+([^\/]+)\.(txt\.)?[0-9].txt.gz$/; my $lang = $1; $lang =~ s/\.txt//; $lang => $_ } 
			grep { ! /___total___/ } 
			bsd_glob($dir."/*.$ngram.txt.gz");

}


sub extendDictionary
{
	my $lang = shift;
	my $file = shift;

	print STDERR "Extending dictionary for language $lang with file: $file\n";

	my $total = 1;
	if ( -f $file ) {
		my $totalFile = $file;
		$totalFile =~ s/txt\.gz/total/;
		open(my $fhT, "<", $totalFile);
		$total = <$fhT>;
		chomp $total;
		close($fhT);
	}

	
	open(my $fh, "<:gzip:bytes", $file);

	my $sum = 0;
	while ( <$fh> ) {
		chomp;
		my @p = split(/\t/, $_);
		my $word = $p[0];
		if ( ! defined($dictionary{$word}) ) {
			$dictionarySize++;
			$dictionary{$word} = $dictionarySize;
			push(@dictionaryKeys, $word);
		}
		$frequency{$word}{$lang} = $p[1];
		$sum += $p[1];
	}

	my $divider = $total;
	if ( $freqNorm == 1 ) {
		$divider = $sum;
	}

	for my $word (keys %frequency) {
		if ( defined($frequency{$word}{$lang}) ) {
			$frequency{$word}{$lang} /= $divider;
		}
	}

	print STDERR "\tDictionary size: $dictionarySize\n";

	close($fh);
}

sub my_open {
  my $f = shift;
  if ($f eq "-") {
    binmode(STDIN, ":utf8");
    return *STDIN;
  }

  die "Not found: $f" if ! -e $f;

  my $opn;
  my $hdl;
  my $ft = `file '$f'`;
  # file might not recognize some files!
  if ($f =~ /\.gz$/ || $ft =~ /gzip compressed data/) {
    $opn = "zcat $f |";
  } elsif ($f =~ /\.bz2$/ || $ft =~ /bzip2 compressed data/) {
    $opn = "bzcat $f |";
  } else {
    $opn = "$f";
  }
  open $hdl, $opn or die "Can't open '$opn': $!";
  binmode $hdl, ":bytes";
  return $hdl;
}

sub help
{
	print "\nNapoveda\n";

	die();

}

