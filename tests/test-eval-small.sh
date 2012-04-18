#!/bin/bash

source test-config.sh

echo "Downloading list of languages";
DIR_LANGUAGES=languages-list
if [ ! -d $DIR_LANGUAGES ]; then 
	mkdir -p $DIR_LANGUAGES;
	cd $DIR_LANGUAGES;
	wget 'http://ufal.mff.cuni.cz/~majlis/yali/download.php?file=languages.tar.gz' -O - | tar -xz;
	cd ..;
fi;

echo "Downloading pretrained models";
DIR_MODEL=model.limited-800;
if [ ! -d $DIR_MODEL ]; then
	wget 'http://ufal.mff.cuni.cz/~majlis/yali/download.php?file=model.tar.gz' -O - | tar -xz;
fi;

echo "Downloading dataset";
DIR_DATASET_SMALL=yali-dataset-small
if [ ! -d $DIR_DATASET_SMALL ]; then 
	wget 'http://ufal.mff.cuni.cz/~majlis/yali/download.php?file=yali-dataset-small.tar.gz' -O - | tar -xz;
fi;

echo "Evaluating dataset with sample length 140 bytes";
RESULT_FILE=yali-small-140-results.txt;
find $DIR_DATASET_SMALL -type f | grep '/140/' | \
	../detector-perl/detect.pl \
	--ngram=4 --dict=$DIR_MODEL \
	--lang-file=$DIR_LANGUAGES/languages-google.txt \
	--freq-norm=1 \
	> $RESULT_FILE;

cat $RESULT_FILE | ../eval.pl


