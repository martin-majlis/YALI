use strict;
use warnings;

use Test::More tests => 4;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $tmp_file = "tmp.yali-builder.out.gz";
my $rm_cmd = "rm -rf tmp.*";

my $class_file = dirname(__FILE__) . "/../Identifier/classes.list";
my $input_file = dirname(__FILE__) . "/../Identifier/files.txt";

my $cmd_base = dirname(__FILE__) . "/../../bin/yali-identifier";
my $cmd_suffix = " -c=$class_file";

exit_is_num($cmd_base . " -i=adasdasd --filelist=aaa" . $cmd_suffix, 101);
exit_is_num($cmd_base . " --filelist=nonexisting_file " . $cmd_suffix, 2);

exit_is_num($cmd_base . " --filelist=$input_file " . $cmd_suffix, 0);

stdout_is_eq($cmd_base . " --filelist=$input_file " . $cmd_suffix, "a\nb\n", "--filelist=file");

# TODO add option for specifying working dir

#stdout_is_eq("cat $input_file | " . $cmd_base . " --filelist=- " . $cmd_suffix, "ces\neng\n", "--input=-");
#stderr_is_eq("cat $input_file | " . $cmd_base . " --filelist=- " . $cmd_suffix, "ces\neng\n", "--input=-");
#exit_is_num("cat $input_file | " . $cmd_base . " --filelist=- " . $cmd_suffix, 0);
