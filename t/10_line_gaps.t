#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;

use OCR::hOCR::Analyze;
my $class = 'OCR::hOCR::Analyze';
my $object = OCR::hOCR::Analyze->new;

my $para_node = {'l' => 50, 'r' => 100};


my $para_cases = [
  # block
  {
    'lines' => [
    	{'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'block',
    'comment' => '1 line equal',
  },
  {
    'lines' => [
    	{'l' => 53, 'r' => 97, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'block',
    'comment' => '1 line equal within threshold',
  },
  {
    'lines' => [
    	{'l' => 53, 'r' => 97, 't' => 10, 'b' => 20,},
    	{'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'block',
    'comment' => '2 lines equal within threshold',
  },
  {
    'lines' => [
    	{'l' => 53, 'r' => 97, 't' => 10, 'b' => 20,},
    	{'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
    	{'l' => 59, 'r' => 100, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'block',
    'comment' => '3 lines equal within threshold',
  },
  # centered
  {
    'lines' => [
    	{'l' => 61, 'r' => 89, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'centered',
    'comment' => '1 line centered',
  },
  {
    'lines' => [
    	{'l' => 61, 'r' => 89, 't' => 10, 'b' => 20,},
    	{'l' => 69, 'r' => 81, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'centered',
    'comment' => '2 lines centered',
  },
  {
    'lines' => [
    	{'l' => 69, 'r' => 81, 't' => 10, 'b' => 20,},
    	{'l' => 61, 'r' => 89, 't' => 10, 'b' => 20,},
    	{'l' => 69, 'r' => 81, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'centered',
    'comment' => '3 lines centered',
  },
  # intended
  {
    'lines' => [
    	{'l' => 61, 'r' => 65, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'intended',
    'comment' => '1 line unsymmetric',
  },
  #{
  #  'lines' => [
  #  	{'l' => 61, 'r' => 100, 't' => 10, 'b' => 20,},
  #  ],
  #  'expect' => 'intended',
  #  'comment' => '1 line left gap',
  #},
  {
    'lines' => [
    	{'l' => 61, 'r' => 100, 't' => 10, 'b' => 20,},
    	{'l' => 50, 'r' => 89, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'intended',
    'comment' => '1 line left, 1 right gap',
  },
  {
    'lines' => [
    	{'l' => 61, 'r' => 100, 't' => 10, 'b' => 20,},
    	{'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
    ],
    'expect' => 'intended',
    'comment' => '1 line left gap, 1 no gap',
  },
];

for my $case (@{$para_cases}) {
  ok(exists OCR::hOCR::Analyze::_para_style($para_node,$case->{'lines'})->{$case->{'expect'}},'_para_style '.$case->{'comment'});
}

my $gap_cases = [
  {
    'line' => {'l' => 50, 'r' => 100, 't' => 10, 'b' => 20,},
    'expect' => {'l' => 0, 'r' => 0,},
    'comment' => 'no_gap',
  },
  {
    'line' => {'l' => 63, 'r' => 100, 't' => 10, 'b' => 20,},
    'expect' => {'l' => 1, 'r' => 0,},
    'comment' => 'left',
  },
  {
    'line' => {'l' => 50, 'r' => 80, 't' => 10, 'b' => 20,},
    'expect' => {'l' => 0, 'r' => 1,},
    'comment' => 'right',
  },
    {
    'line' => {'l' => 70, 'r' => 80, 't' => 10, 'b' => 20,},
    'expect' => {'l' => 1, 'r' => 1,},
    'comment' => 'symmetric',
  },
];

for my $case (@{$gap_cases}) {
  is(OCR::hOCR::Analyze::line_gap($para_node,$case->{'line'}),$case->{'comment'},'line_gap '.$case->{'comment'});
  #is(&{$class . '::line_gap'($para_node,$case->{'line'}),$case->{'comment'},'line_gap '.$case->{'comment'});
}


done_testing;
