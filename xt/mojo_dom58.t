#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

binmode(STDOUT,":encoding(UTF-8)");
binmode(STDERR,":encoding(UTF-8)");

use Data::Dumper;
use Mojo::DOM58;
use JSON::MaybeXS qw(JSON);
#use JSON::PP ();

my $html =<<'HTML';
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




if (1) {
my $dom = Mojo::DOM58->new->parse($html);
my $tree = $dom->tree();
#print Dumper( $dom->tree() );
print $dom->xml(0)->to_string,"\n";
#print JSON->new->convert_blessed->pretty(1)->encode($tree);
}


sub c { Mojo::DOM58::_Collection->new(@_) }
#print JSON->new->convert_blessed->pretty(1)->encode([Mojo::DOM58->new($html)]);

# too many recursions
#print JSON::PP->new->convert_blessed->pretty(1)->encode([Mojo::DOM58->new($html)->tree(['root'])]);
