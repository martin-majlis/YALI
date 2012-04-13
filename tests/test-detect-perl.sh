#!/bin/bash

source test-config.sh

mkdir -p $DIR_TEST;

if [ ! -f $FILE_TEST_A ]; then
	perl -e 'for $i (0 ... 1000) { print "a" x rand(5), " "; }; print "\n";' > $FILE_TEST_A;
fi;

if [ ! -f $FILE_TEST_B ]; then
	perl -e 'for $i (0 ... 1000) { print "b" x rand(5), " "; }; print "\n";' > $FILE_TEST_B;
fi;

echo -e "aaa\nbbb" > $FILE_LANGS;

find $DIR_TEST -type f | ../detector-perl/detect.pl --ngram=4 --dict=$DIR_MODEL --lang-file=$FILE_LANGS --freq-norm=1
