#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;

use Data::Dumper;

use OCR::hOCR::Analyze;
my $class = 'OCR::hOCR::Analyze';

my $gap_cases = [
[
  {'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
  {'l' => 63, 'r' => 100, 't' => 9, 'b' => 20,},
  {'l' => 50, 'r' => 80, 't' => 10, 'b' => 20,},
  {'l' => 70, 'r' => 80, 't' => 10, 'b' => 30,},
],
];

for my $case (@{$gap_cases}) {
  ok(OCR::hOCR::Analyze::_envelope($case));
  #is(&{$class . '::line_gap'($para_node,$case->{'line'}),$case->{'comment'},'line_gap '.$case->{'comment'});
  print Dumper(OCR::hOCR::Analyze::_envelope($case));
}


done_testing;
