#!/bin/bash

source test-config.sh

if [ ! -f $FILE_TRAIN_A ]; then
	perl -e 'for $i (0 ... 1000) { print "a" x rand(10), " "; }; print "\n";' > $FILE_TRAIN_A;
fi;

if [ ! -f $FILE_TRAIN_B ]; then
	perl -e 'for $i (0 ... 1000) { print "b" x rand(10), " "; }; print "\n";' > $FILE_TRAIN_B;
fi;

echo -e "aaa\t${FILE_TRAIN_A}\nbbb\t${FILE_TRAIN_B}" > $FILE_TRAIN_FL;

../build-model.pl --ngram=4 --fl=$FILE_TRAIN_FL --out=$DIR_MODEL;




