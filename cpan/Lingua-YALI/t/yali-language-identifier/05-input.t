use strict;
use warnings;

use Test::More tests => 11;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $tmp_file = "tmp.yali-builder.out.gz";
my $rm_cmd = "rm -rf tmp.*";

my $input_file = dirname(__FILE__) . "/../LanguageIdentifier/ces01.txt";

my $cmd_base = dirname(__FILE__) . "/../../bin/yali-language-identifier";
my $cmd_suffix = " -l='ces eng'";

exit_is_num($cmd_base . " -i=adasdasd --filelist=aaa" . $cmd_suffix, 101);
exit_is_num($cmd_base . " -i=nonexisting_file " . $cmd_suffix, 2);

exit_is_num($cmd_base . " -i=$input_file " . $cmd_suffix, 0);
exit_is_num("cat $input_file | " . $cmd_base . " -i=- " . $cmd_suffix, 0);
exit_is_num("cat $input_file | " . $cmd_base . " " . $cmd_suffix, 0);

stdout_is_eq($cmd_base . " -i=$input_file " . $cmd_suffix, "ces\n", "-i=file");
stdout_is_eq("cat $input_file | " . $cmd_base . " -i=- " . $cmd_suffix, "ces\n", "-i=-");
stdout_is_eq("cat $input_file | " . $cmd_base . " " . $cmd_suffix, "ces\n", "-i is ommited");

stdout_is_eq($cmd_base . " --input=$input_file " . $cmd_suffix, "ces\n", "--input=file");
stdout_is_eq("cat $input_file | " . $cmd_base . " --input=- " . $cmd_suffix, "ces\n", "--input=-");
stdout_is_eq("cat $input_file | " . $cmd_base . " " . $cmd_suffix, "ces\n", "--input is ommited");
