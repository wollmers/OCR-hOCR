package OCR::hOCR::Spec;

use utf8;

use strict;
use warnings;

our $VERSION = '0.01';

our $hOCR_spec = {};

my $grammar = {
'Properties Grammar' => {
    'digit' => '%x30-39',
    'uint' => '+digit',
    'int' => '*1"-" uint',
    'nint' => '"-" uint',
    'fraction' => '"." uint',
    'float' => '*uint fraction',

    'whitespace' => '+%20',
    'comma' => '%2C',
    'semicolon' => '%3B',
    'doublequote' => '%22',
    'lowercase-letter' => '%x41-5A',
    'alnum-word' => '+(lowercase-letter / digit)',
    'ascii-word' => '+(%x21-7E - semicolon)',
    'ascii-string' => '+(%x01-FF - semicolon)',
    'delimited-string' => 'doublequote ascii-string doublequote',

    'properties-format' => 'key-value-pair *(whitespace semicolon key-value-pair)',
    'spec-property-name' => '("bbox" / "baseline" / "cflow" / "cuts" / "hardbreak" /
                      "image" / "imagemd5" / "lpageno" / "nlp" / "order" /
                      "poly" / "ppageno" / "scan_res" / "textangle" /
                      "x_bboxes" / "x_confs" / "x_font" / "x_fsize" /
                      "x_scanner" / "x_source" / "x_wconf" )',
    'engine-property-name' => '"x_" alnum-word',
    'key-value-pair' => 'property-name whitespace property-value',
    'property-name' => 'spec-property-name / engine-property-name',
    'property-value' => 'ascii-word *(whitespace ascii-word)',
},
};

my $elements = {
'Elements' => {
  'ocr_page', => {
    'Name' => 'ocr_page',
    'Properties' => {
        'Required' => ['bbox'],
        'Recommended' => ['image, imagemd5'],
        'Allowed' => ['x_source'],
    },
  },
  'ocr_carea', => {
    'Name' => 'ocr_carea',
    'Categories' => ['Typesetting Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_line', => {
    'Name' => 'ocr_line',
    'Categories' => ['Typesetting Elements'],
    'Properties' => {
        'Required' => ['bbox'],
        'Allowed' => ['baseline', 'hardbreak', 'x_font', 'x_fsize', 'x_bboxes'],
    },
  },
  'ocr_separator', => {
    'Name' => 'ocr_separator',
    'Categories' => ['Typesetting Elements', 'Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_noise', => {
    'Name' => 'ocr_noise',
    'Categories' => ['Inline Elements'],
  },
  'ocr_float', => {
    'Name' => 'ocr_float',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_textfloat', => {
    'Name' => 'ocr_textfloat',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_textimage', => {
    'Name' => 'ocr_textimage',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_image', => {
    'Name' => 'ocr_image',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_linedrawing', => {
    'Name' => 'ocr_linedrawing',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_photo', => {
    'Name' => 'ocr_photo',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_header', => {
    'Name' => 'ocr_header',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_footer', => {
    'Name' => 'ocr_footer',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_pageno', => {
    'Name' => 'ocr_pageno',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_table', => {
    'Name' => 'ocr_table',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_document', => {
    'Name' => 'ocr_document',
    'Recommended HTML Tags' => ['div'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_title', => {
    'Name' => 'ocr_title',
    'Recommended HTML Tags' => ['h1'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_author', => {
    'Name' => 'ocr_author',
    'Categories' => ['Logical Elements'],
  },
  'ocr_abstract', => {
    'Name' => 'ocr_abstract',
    'Categories' => ['Logical Elements'],
  },
  'ocr_part', => {
    'Name' => 'ocr_part',
    'Recommended HTML Tags' => ['h1'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_chapter', => {
    'Name' => 'ocr_chapter',
    'Recommended HTML Tags' => ['h1'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_section', => {
    'Name' => 'ocr_section',
    'Recommended HTML Tags' => ['h2'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_subsection', => {
    'Name' => 'ocr_subsection',
    'Recommended HTML Tags' => ['h3'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_subsubsection', => {
    'Name' => 'ocr_subsubsection',
    'Recommended HTML Tags' => ['h4'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_display', => {
    'Name' => 'ocr_display',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_blockquote', => {
    'Name' => 'ocr_blockquote',
    'Recommended HTML Tags' => ['blockquote'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_par', => {
    'Name' => 'ocr_par',
    'Recommended HTML Tags' => ['p'],
    'Categories' => ['Logical Elements'],
  },
  'ocr_linear', => {
    'Name' => 'ocr_linear',
    'Categories' => ['Typesetting Elements'],
  },
  'ocr_caption', => {
    'Name' => 'ocr_caption',
    'Categories' => ['Logical Elements'],
  },
  'ocr_glyph', => {
    'Name' => 'ocr_glyph',
    'Categories' => ['Inline Elements'],
  },
  'ocr_glyphs', => {
    'Name' => 'ocr_glyphs',
    'Categories' => ['Inline Elements'],
  },
  'ocr_dropcap', => {
    'Name' => 'ocr_dropcap',
    'Categories' => ['Inline Elements'],
  },
  'ocr_math', => {
    'Name' => 'ocr_math',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocr_chem', => {
    'Name' => 'ocr_chem',
    'Categories' => ['Float Elements'],
    'Properties' => {
        'Required' => ['bbox'],
    },
  },
  'ocrx_block', => {
    'Name' => 'ocrx_block',
    'Categories' => ['Inline Elements', 'Engine-Specific Elements'],
  },
  'ocrx_line', => {
    'Name' => 'ocrx_line',
    'Categories' => ['Inline Elements', 'Engine-Specific Elements'],
  },
  'ocrx_word', => {
    'Name' => 'ocrx_word',
    'Categories' => ['Inline Elements', 'Engine-Specific Elements'],
  },

},
};

my $properties = {

'Properties' => {
  'baseline', => {
    'Name' => 'baseline',
    'Categories' => ['Inline'],
    'Grammar' => {
      'property-name' => 'baseline',
      'property-value' => 'float int',
    },
    'Example' => 'baseline 0.015 -18',
  },
  'bbox', => {
    'Name' => 'bbox',
    'Categories' => ['General', 'Layout'],
    'Conflicting' => ['bbox'],
    'Grammar' => {
      'property-name' => 'bbox',
      'property-value' => 'uint uint uint uint',
    },
    'Example' => 'bbox 0 0 100 200',
  },
  'cflow', => {
    'Name' => 'cflow',
    'Categories' => ['Content Flow'],
    'Grammar' => {
      'property-name' => 'cflow',
      'property-value' => 'delimited-string',
    },
    'Example' => 'cflow "article1"',
  },
  'cuts', => {
    'Name' => 'cuts',
    'Categories' => ['Layout', 'Character'],
    'Related' => ['nlp', 'x_bboxes'],
    'Implied' => ['bbox'],
    'Grammar' => {
      'property-name' => 'cuts',
      'property-value' => '+(uint *1(comma uint *1(comma nint)))',
    },
    'Example' => 'cuts 9 11 7,8,-2 15 3',
  },
  'hardbreak', => {
    'Name' => 'hardbreak',
    'Categories' => ['Inline'],
    'Grammar' => {
      'property-name' => 'hardbreak',
      'property-value' => '"0" / "1"',
    },
    'Default Value' => 'hardbreak 0',
  },
  'image', => {
    'Name' => 'image',
    'Categories' => ['Page'],
    'Related' => ['imagemd5, x_source'],
    'Grammar' => {
      'property-name' => 'image',
      'property-value' => 'delimited-string',
    },
    'Example' => 'image "/foo/bar.png"',
  },
  'imagemd5', => {
    'Name' => 'imagemd5',
    'Categories' => ['Page'],
    'Implied' => ['image'],
    'Grammar' => {
      'property-name' => 'imagemd5',
      'property-value' => 'doublequote 32(%x41-46 / digit) doublequote',
    },
  },
  'lpageno', => {
    'Name' => 'lpageno',
    'Categories' => ['Page'],
    'Related' => ['ppageno'],
    'Grammar' => {
      'property-name' => 'lpageno',
      'property-value' => 'delimited-string / uint',
    },
    'Example' => 'lpageno "IV."',
  },
  'ppageno', => {
    'Name' => 'ppageno',
    'Categories' => ['Page'],
    'Related' => ['lpageno'],
    'Grammar' => {
      'property-name' => 'ppageno',
      'property-value' => 'uint',
    },
    'Example' => 'lpageno 7',
  },
  'nlp', => {
    'Name' => 'nlp',
    'Categories' => ['Confidence', 'Character'],
    'Related' => ['cuts', 'x_confs'],
    'Implied' => ['cuts'],
    'Grammar' => {
      'property-name' => 'nlp',
      'property-value' => '+float',
    },
  },
  'order', => {
    'Name' => 'order',
    'Categories' => ['Content Flow'],
    'Grammar' => {
      'property-name' => 'order',
      'property-value' => '+uint',
    },
    'Example' => 'order 8',
  },
  'poly', => {
    'Name' => 'poly',
    'Categories' => ['Layout', 'Non-recommended'],
    'Conflicting' => ['bbox'],
    'Grammar' => {
      'property-name' => 'poly',
      'property-value' => '2uint 2int *(2int)',
    },
    'Example' => 'poly 0 0 0 10 10 10 10 20 0 20',
  },
  'scan_res', => {
    'Name' => 'scan_res',
    'Categories' => ['Page'],
    'Related' => ['x_scanner'],
    'Grammar' => {
      'property-name' => 'scan_res',
      'property-value' => '2(uint)',
    },
    'Example' => 'scan_res 300 300',
  },
  'textangle', => {
    'Name' => 'textangle',
    'Categories' => ['Layout'],
    'Grammar' => {
      'property-name' => 'textangle',
      'property-value' => 'float',
    },
    'Example' => 'textangle 7.32',
  },
  'x_bboxes', => {
    'Name' => 'x_bboxes',
    'Categories' => ['Inline', 'Character'],
    'Related' => ['cuts'],
    'Grammar' => {
      'property-name' => 'x_bboxes',
      'property-value' => '1*(4uint)',
    },
    'Example' => 'x_bboxes 0 0 10 10 0 10 20 20',
  },
  'x_font', => {
    'Name' => 'x_font',
    'Categories' => ['Font'],
    'Related' => ['x_fsize'],
    'Grammar' => {
      'property-name' => 'x_font',
      'property-value' => 'delimited-string',
    },
    'Example' => 'x_font "Comic Sans MS"',
  },
  'x_fsize', => {
    'Name' => 'x_fsize',
    'Categories' => ['Font'],
    'Related' => ['x_font'],
    'Grammar' => {
      'property-name' => 'x_fsize',
      'property-value' => 'uint',
    },
    'Example' => 'x_fsize 12',
  },
  'x_confs', => {
    'Name' => 'x_confs',
    'Categories' => ['Confidence', 'Character'],
    'Grammar' => {
      'property-name' => 'x_confs',
      'property-value' => '+float',
    },
    'Example' => 'x_confs 37.3 51.23 1 100',
  },
  'x_scanner', => {
    'Name' => 'x_scanner',
    'Categories' => ['Page'],
    'Related' => ['scan_res'],
    'Grammar' => {
      'property-name' => 'x_scanner',
      'property-value' => 'delimited-string',
    },
    'Example' => 'scanner "Canon Lide 220"',
  },
  'x_source', => {
    'Name' => 'x_source',
    'Categories' => ['Page'],
    'Related' => ['image'],
    'Grammar' => {
      'property-name' => 'x_source',
      'property-value' => '1*delimited-string',
    },
    'Example' => 'x_source "/gfs/cc/clean/012345678911" "17"',
  },
  'x_wconf', => {
    'Name' => 'x_wconf',
    'Categories' => ['Confidence', 'Inline'],
    'Grammar' => {
      'property-name' => 'x_wconf',
      'property-value' => 'float',
    },
    'Example' => 'x_wconf 97.23',
  },
},
};



1;
