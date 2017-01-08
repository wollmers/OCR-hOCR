#!perl
use 5.008;

use strict;
use warnings;
use utf8;

use lib qw(../lib/);

binmode(STDOUT,":encoding(UTF-8)");
binmode(STDERR,":encoding(UTF-8)");

use Data::Dumper;
use OCR::hOCR;
use OCR::hOCR::Analyze;

#my $object = OCR::hOCR->new();

my $files = {
	'cun_1.0'   => 'data/biostor-146511_01.cun.hocr',
	'kraken'    => 'data/biostor-146511_02.kraken.hocr',
	'tes3.05'  => 'data/isis_152.5_01.deu_frak+deu.tess_3.05.hocr',
	'ocropy'    => 'data/ocropy.hocr',
	'tes3.04'  => 'data/isis_tess_3.04.hocr',
};

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
     <span class='ocr_line' id='line_1_1' title="bbox 37 60 109 95; baseline -0.014 0; x_size 45.666668; x_descenders 11.416667; x_ascenders 11.416667"><span class='ocrx_word page_no' id='word_1_1' title='bbox 37 60 109 95; x_wconf 79'>249</span>
     </span>
    </p>
   </div>
  </div>
</body>
</html>
HTML


if (0) {
  #print '*** ',$file,"\n";
  my $id = 'tes_3.05';
  my $object = OCR::hOCR->new();
  my $html = $object->parse($html_string);
  #print '$html: ',Dumper($html);

  $object->index;

  my $analyze = OCR::hOCR::Analyze->new();
  my $page_id = $object->{'type'}->{'ocr_page'}->[0];

  my $column_sizes = $analyze->columns($object,$page_id);
  print Dumper($column_sizes);
  my $float_areas = $analyze->float_areas($object,$page_id);
  print Dumper($float_areas);
}

if (0) {
  for my $id (keys %{$files}) {
    my $file = $files->{$id};
    print '*** ',$file,"\n";

    my $object = OCR::hOCR->new();
    my $html = $object->parsefile($file);

    $object->index;

    my $analyze = OCR::hOCR::Analyze->new();
    my $page_id = $object->{'type'}->{'ocr_page'}->[0];

    my $column_sizes = $analyze->columns($object,$page_id);
    print Dumper($column_sizes);
    my $float_areas = $analyze->float_areas($object,$page_id);
    print Dumper($float_areas);
  }
}

if (1) {
  #for my $id (keys %{$files}) {
    my $file = $files->{'tes3.05'};
    print '*** ',$file,"\n";

    my $object = OCR::hOCR->new();
    my $html = $object->parsefile($file);

    $object->index;

    my $analyze = OCR::hOCR::Analyze->new();
    $analyze->stats($object);
    my $page_id = $object->{'type'}->{'ocr_page'}->[0];

    my $column_sizes = $analyze->columns($object,$page_id);
    #print Dumper($column_sizes);

    print '$column_sizes',"\n";
    for my $col_num (sort {$a <=> $b} keys %$column_sizes) {
      my $count = 0;
      for my $col (keys %{$column_sizes->{$col_num}}) {
        if (exists $column_sizes->{$col_num}->{$col}) {
          $count += scalar(@{$column_sizes->{$col_num}->{$col}});
        }
      }
      print $col_num,': ',$count,"\n" if ($count);
    }

    my $float_areas = $analyze->float_areas($object,$page_id);
    #print Dumper($float_areas);

    print '$float_areas',"\n";
    for my $col_num (sort {$a <=> $b} keys %$float_areas) {
      my $count = 0;
      for my $col (keys %{$float_areas->{$col_num}}) {
        if (exists $float_areas->{$col_num}->{$col}) {
          $count += scalar(@{$float_areas->{$col_num}->{$col}});
        }
      }
      print $col_num,': ',$count,"\n" if ($count);
    }
  #}
}

