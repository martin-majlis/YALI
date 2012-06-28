use strict;
use warnings;

use Test::More tests => 6;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $tmp_file = "tmp.yali-builder.out.gz";
my $rm_cmd = "rm -rf tmp.*";

my $cmd_pref = " ";
my $cmd_base = dirname(__FILE__) . "/../../bin/yali-language-identifier";
my $cmd_suffix = "";

exit_is_num($cmd_pref . $cmd_base . " --supported=-10" . $cmd_suffix, 105);
exit_is_num($cmd_pref . $cmd_base . " -s=-10" . $cmd_suffix, 105);

exit_is_num($cmd_pref . $cmd_base . " -s " . $cmd_suffix, 0);

exit_is_num($cmd_pref . $cmd_base . " --supported" . $cmd_suffix, 0);

stdout_is_eq($cmd_pref . $cmd_base . " -s " . $cmd_suffix . " | wc -l", "122\n", "there is 122 supported languages");
stdout_is_eq($cmd_pref . $cmd_base . " -s " . $cmd_suffix . " | wc -c", "488\n", "there is 122 supported languages");
