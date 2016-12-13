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
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
 <head>
  <title></title>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
  <meta name='ocr-system' content='tesseract 3.05.00dev' />
  <meta name='ocr-capabilities' content='ocr_page ocr_carea ocr_par ocr_line ocrx_word'/>
</head>
<body>
  <div class='ocr_page' id='page_1' title='image "isis_152.png"; bbox 0 0 2321 2817; ppageno 0'>
   <div class='ocr_carea' id='block_1_1' title="bbox 37 60 109 95">
    <p class='ocr_par' id='par_1_1' lang='deu' title="bbox 37 60 109 95">
     <span class='ocr_line' id='line_1_1' title="bbox 37 60 109 95; baseline -0.014 0; x_size 45.666668; x_descenders 11.416667; x_ascenders 11.416667"><span class='ocrx_word' id='word_1_1' title='bbox 37 60 109 95; x_wconf 79'>249</span>
     </span>
    </p>
   </div>
   <div class='ocr_carea' id='block_1_2' title="bbox 39 153 1048 236">
    <p class='ocr_par' id='par_1_2' lang='deu' title="bbox 39 153 1048 236">
     <span class='ocr_line' id='line_1_2' title="bbox 142 153 1048 195; baseline -0.007 -5; x_size 38; x_descenders 6; x_ascenders 10"><span class='ocrx_word' id='word_1_2' title='bbox 142 160 175 195; x_wconf 84'>S)</span> <span class='ocrx_word' id='word_1_3' title='bbox 200 157 241 189; x_wconf 81' lang='deu_frak'>G.</span> <span class='ocrx_word' id='word_1_4' title='bbox 270 156 461 193; x_wconf 82' lang='deu_frak'>Valentin,</span> <span class='ocrx_word' id='word_1_5' title='bbox 505 154 565 186; x_wconf 99' lang='deu_frak'>über</span> <span class='ocrx_word' id='word_1_6' title='bbox 594 157 642 184; x_wconf 84' lang='deu_frak'>den</span> <span class='ocrx_word' id='word_1_7' title='bbox 672 153 794 191; x_wconf 77' lang='deu_frak'>Verlauf</span> <span class='ocrx_word' id='word_1_8' title='bbox 821 155 875 184; x_wconf 83' lang='deu_frak'>und</span> <span class='ocrx_word' id='word_1_9' title='bbox 906 155 945 184; x_wconf 84' lang='deu_frak'>die</span> <span class='ocrx_word' id='word_1_10' title='bbox 966 157 1048 191; x_wconf 70' lang='deu_frak'>letzten</span>
     </span>
     <span class='ocr_line' id='line_1_3' title="bbox 39 196 716 236; baseline -0.01 -4; x_size 38; x_descenders 7; x_ascenders 11"><span class='ocrx_word' id='word_1_11' title='bbox 39 200 132 232; x_wconf 86' lang='deu_frak'>Enden</span> <span class='ocrx_word' id='word_1_12' title='bbox 156 204 200 230; x_wconf 89' lang='deu_frak'>der</span> <span class='ocrx_word' id='word_1_13' title='bbox 222 200 338 236; x_wconf 87' lang='deu_frak'>Nerven,</span> <span class='ocrx_word' id='word_1_14' title='bbox 362 200 406 230; x_wconf 88' lang='deu_frak'>S.</span> <span class='ocrx_word' id='word_1_15' title='bbox 429 200 467 230; x_wconf 87'><strong>51</strong></span> <span class='ocrx_word' id='word_1_16' title='bbox 491 199 541 228; x_wconf 85' lang='deu_frak'>mit</span> <span class='ocrx_word' id='word_1_17' title='bbox 564 198 583 227; x_wconf 90'>8</span> <span class='ocrx_word' id='word_1_18' title='bbox 606 196 716 233; x_wconf 88' lang='deu_frak'>Tafeln.</span>
     </span>
    </p>
   </div>
  </div>
 </body>
</html>
HTML

ok($object->parse($html_string),'parses cuneiform');

my $tree = $object->parse($html_string);
print JSON->new->pretty(1)->encode($tree);

done_testing;
