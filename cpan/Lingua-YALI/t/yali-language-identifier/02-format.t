use strict;
use warnings;

use Test::More tests => 14;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $tmp_file = "tmp.yali-builder.out.gz";
my $rm_cmd = "rm -rf tmp.*";

my $cmd_pref = "echo 'ahoj jak' | ";
my $cmd_base = dirname(__FILE__) . "/../../bin/yali-language-identifier";
my $cmd_suffix = " -i=- -l='ces eng'";

exit_is_num($cmd_pref . $cmd_base . " --format=" . $cmd_suffix, 105);
exit_is_num($cmd_pref . $cmd_base . " --format=adads" . $cmd_suffix, 101);

exit_is_num($cmd_pref . $cmd_base . " -f=" . $cmd_suffix, 105);
exit_is_num($cmd_pref . $cmd_base . " -f=adads" . $cmd_suffix, 101);

exit_is_num($cmd_pref . $cmd_base . " --format=single" . $cmd_suffix, 0);
exit_is_num($cmd_pref . $cmd_base . " -f=single " . $cmd_suffix, 0);
exit_is_num($cmd_pref . $cmd_base . " -f=all " . $cmd_suffix, 0);
exit_is_num($cmd_pref . $cmd_base . " -f=all_p " . $cmd_suffix, 0);
exit_is_num($cmd_pref . $cmd_base . " -f=tabbed " . $cmd_suffix, 0);

stdout_is_eq($cmd_pref . $cmd_base . " --format=single" . $cmd_suffix, "ces\n", "format=single");
stdout_is_eq($cmd_pref . $cmd_base . " -f=single " . $cmd_suffix, "ces\n", "format=single");
stdout_is_eq($cmd_pref . $cmd_base . " -f=all " . $cmd_suffix, "ces\teng\n", "format=all");
stdout_is_eq($cmd_pref . $cmd_base . " -f=all_p " . $cmd_suffix, "ces:1\teng:0\n", "format=all_p");
stdout_is_eq($cmd_pref . $cmd_base . " -f=tabbed " . $cmd_suffix, "1\t0\n", "format=tabbed");