#!/bin/bash

FILE_A=test_a
FILE_B=test_b
FILE_FL=test_fl
DIR_MODEL=test_model

if [ ! -f $FILE_A ]; then
	perl -e 'for $i (0 ... 1000) { print "a" x rand(10), " "; }; print "\n";' > $FILE_A;
fi;

if [ ! -f $FILE_B ]; then
	perl -e 'for $i (0 ... 1000) { print "b" x rand(10), " "; }; print "\n";' > $FILE_B;
fi;

echo -e "aaa\t${FILE_A}\nbbb\t${FILE_B}\n" > $FILE_FL;

../build-model.pl --ngram=4 --fl=$FILE_FL --out=$DIR_MODEL;




