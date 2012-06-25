
doc:
	version=`cat dist.ini  | grep version | cut -f3 -d" "`; \
	dzil build; pod2html --infile=Lingua-*-$$version/lib/Lingua/*.pm > doc.html; \
	echo `pwd`/doc.html
	
test-full:
	dzil test

test-simple:
	prove -lr t
	
build:
	version=`cat dist.ini  | grep version | cut -f3 -d" "`; \
	rm -rf Lingua-*-$$version*; \
	dzil build
	
# cd ~/work/devel/YALI/tests/model.limited-1600
# for f in *.4.txt.gz; do echo $f; lang=`echo $f | cut -f1 -d.`; out=~/work/devel/YALI/cpan/Lingua-YALI/lib/auto/Lingua/YALI/$lang.yali; rm $out.*; echo 4 > $out; total=`cat $lang.txt.4.total`; echo -e "___total___\t$total" >> $out; zcat $f >> $out; gzip $out; done
