#!/usr/bin/env perl
use strict;
use warnings;

use sigtrap 'handler' => \&storeModel, 'INT', 'ABRT', 'QUIT', 'TERM';
use File::Path qw(make_path);
use PerlIO::gzip;
use Getopt::Long qw/GetOptionsFromArray/;

binmode(STDOUT, ':bytes');
binmode(STDERR, ':bytes');

my $lineId = 1;
my $wordId = 1;
my %dict = ();
my $ngram = 5;

my $fileList;
my $outDir;

my %opts = (
  ngram => \$ngram,
  out => \$outDir,
  fl => \$fileList
);

my @optionspec = (
  "ngram=i",
  "out=s",
  "fl=s",
);


GetOptions(\%opts, @optionspec) or exit 1;


# ngram
if ( ! defined($ngram) ) {
	print STDERR "N-gram size must be specified! (--ngram)\n";
	help();
}

# file list
if ( ! defined($fileList) ) {
	print STDERR "Path to file list must be specified! (--fl)\n";
	help();
}

if ( ! -f $fileList ) {
	print STDERR "File list [$fileList] doesn\'t exist.\n";
	help();
}

# output dir
if ( ! defined($outDir) ) {
	print STDERR "Path to output directory must be specified! (--output)\n";
	help();
}




my $sub = "";
my $subsub = "";
my $padding = ' ' x ($ngram - 1);


my @files = ();

open(my $fhList, "<", $fileList) or die $fileList . ": " . $!;

while ( <$fhList> ) {
	chomp;
	next if ! $_;
	
	my ($code, $file) = split(/\t/, $_);
	push(@files, [$code, $file]);

	print STDERR "\nReading file: $file\n";
	
	if ( ! -f $file ) {
	    print STDERR "Skipping $_\n";
	    next;
	}

	my $fh = my_open($file);

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
				$sub = substr($_, $i, $ngram);
				for my $j (1 .. $ngram) {
#				for my $j ($ngram .. $ngram) {
					$subsub = bytes::substr($sub, 0, $j);
#					if ( $subsub =~ /[[:digit:][:punct:]]/ ) {
#						next;
#					}
					if ( ! defined($dict{$j}{$subsub}) ) {
						$dict{$j}{$subsub}{___total___} = 0;
						$wordId++;
					}
					$dict{$j}{$subsub}{___total___}++;
					$dict{$j}{$subsub}{$code}++;
				}
			}
		}

		if ( $lineId % 1000 == 0 ) {
			print STDERR "*";
			if ( $lineId % 10000 == 0 ) {
				print STDERR "\t" . sprintf("%9d\t%9d\n", $lineId, $wordId) ;
			}
		}
		$lineId++;
	}
	close($fh);
}

print STDERR "\n\n";
print STDERR "Total\nLines: $lineId\nWordIds: $wordId\n";

storeModel();

sub storeModel
{
	print STDERR "\n";
	make_path($outDir); 

	push(@files, ['___total___', '___total___']);

	for my $item (sort { $a->[0] cmp $b->[0] } @files) {
		my $code = $item->[0];

		for my $j (1 .. $ngram) {

			my $outFile = $code . ".$j". ".txt.gz";

			print STDERR "Storing model for $code and $j to $outFile\n";
		
			open(my $fhModel, ">:gzip:bytes", $outDir. "/" . $outFile) or die $!;
		
			{
				no warnings;
				my %resDict = ();
				for my $k (keys %{$dict{$j}}) {
					if ( defined($dict{$j}{$k}{$code}) ) {
						$resDict{$k} = $dict{$j}{$k}{$code};
					}
				}

				for my $k (sort { $resDict{$b} <=> $resDict{$a} } keys %resDict) {
					print $fhModel "$k\t$resDict{$k}\n";
				}
			}
	
			close($fhModel);
		}
	}


	exit 0;
}



sub my_open {
  my $f = shift;
  if ($f eq "-") {
    binmode(STDIN, ":bytes");
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
	print <<DOC;
Usage:
build-model.pl --ngram=N --fl=file-list --out=output-dir 

Creates model for YALI recognizer.

    --ngram=N
        Ngram size.
    --fl=FILE
        File with list of files used for building models.
        This file contains two columns, the first one 
        with languge code and the second one with path to text file
    --out=DIR
        Output directory for created models.

DOC
	


exit(0);

}
