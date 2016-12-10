#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;

my $class = 'OCR::hOCR::Spec';

use_ok($class);

done_testing;
