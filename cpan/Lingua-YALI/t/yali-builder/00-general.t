use strict;
use warnings;

use Test::More tests => 3;
use Time::HiRes;
use Test::Command;
use File::Basename;

my $cmd_base = dirname(__FILE__) . "/../../bin/yali-builder";

ok(-x $cmd_base);

exit_is_num($cmd_base . " --unknownoption", 5);
exit_is_num($cmd_base, 2);

