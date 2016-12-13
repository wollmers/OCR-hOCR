#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

use Test::More;
use JSON::MaybeXS qw(JSON);

my $class = 'OCR::hOCR';

use_ok($class);

my $object = new_ok($class);

my $html_string =<<'HTML';
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html><head><title></title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<meta name='ocr-system' content='openocr'>
</head>
<body><div class='ocr_page' id='page_1' title='image "biostor-146511_02.png"; bbox 0 0 1742 2808'>
<p align=justify><span class='ocr_line' id='line_3' title="bbox 191 320 1648 359">camera<br> (Leica DFC425) </span></p>
</div>
</body>
</html>
HTML

ok($object->parse($html_string),'parses cuneiform');

my $tree = $object->parse($html_string);
print JSON->new->pretty(1)->encode($tree);

done_testing;
