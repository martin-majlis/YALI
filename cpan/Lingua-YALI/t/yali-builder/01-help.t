use strict;
use warnings;

use Test::More tests => 2;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $cmd_base = dirname(__FILE__) . "/../../bin/yali-builder";

exit_is_num($cmd_base . " --help", 0);
exit_is_num($cmd_base . " -h", 0);
