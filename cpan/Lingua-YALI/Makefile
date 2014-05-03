
doc:
	version=`cat dist.ini  | grep version | cut -f3 -d" "`; \
	dzil build; \
	podchecker Lingua-YALI-$$version/lib/Lingua/YALI/Builder.pm; \
	podchecker Lingua-YALI-$$version/lib/Lingua/YALI/Identifier.pm; \
	podchecker Lingua-YALI-$$version/lib/Lingua/YALI/LanguageIdentifier.pm; \
	podchecker Lingua-YALI-$$version/lib/Lingua/YALI.pm; \
	podchecker Lingua-YALI-$$version/lib/Lingua/YALI/Examples.pod; \
	podchecker Lingua-YALI-$$version/bin/yali-language-identifier; \
	podchecker Lingua-YALI-$$version/bin/yali-identifier; \
	podchecker Lingua-YALI-$$version/bin/yali-builder; \
	pod2html --infile=Lingua-YALI-$$version/lib/Lingua/YALI/Builder.pm > doc_Builder.html; \
	pod2html --infile=Lingua-YALI-$$version/lib/Lingua/YALI/Identifier.pm > doc_Identifier.html; \
	pod2html --infile=Lingua-YALI-$$version/lib/Lingua/YALI/LanguageIdentifier.pm > doc_LanguageIdentifier.html; \
	pod2html --infile=Lingua-YALI-$$version/lib/Lingua/YALI/Examples.pod > doc_Examples.html; \
	pod2html --infile=Lingua-YALI-$$version/lib/Lingua/YALI.pm > doc_YALI.html; \
	pod2html --infile=Lingua-YALI-$$version/bin/yali-language-identifier > doc_yali-language-identifier.html; \
	pod2html --infile=Lingua-YALI-$$version/bin/yali-identifier > doc_yali-identifier.html; \
	pod2html --infile=Lingua-YALI-$$version/bin/yali-builder > doc_yali-builder.html; \
	
test-full:
	dzil test

test-simple:
	prove -lr t
	
build:
	version=`cat dist.ini  | grep version | cut -f3 -d" "`; \
	date=`date +"%Y-%m-%d"`; \
	for file in bin/*; do \
		sed -ri "s/^Version.*/Version: $$version ($$date)/" $$file; \
	done; \
	rm -rf Lingua-*-$$version*; \
	find . -name '*~' -exec rm {} \; ; \
	dzil build

release: build
	rm -v doc_*; \
	dzil release;

	
# cd ~/work/devel/YALI/tests/model.limited-1600
# for f in *.4.txt.gz; do echo $f; lang=`echo $f | cut -f1 -d.`; out=~/work/devel/YALI/cpan/Lingua-YALI/lib/auto/Lingua/YALI/$lang.yali; rm $out.*; echo 4 > $out; total=`cat $lang.txt.4.total`; echo -e "___total___\t$total" >> $out; zcat $f >> $out; gzip $out; done
