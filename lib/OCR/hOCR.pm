package OCR::hOCR;
use utf8;

use strict;
use warnings;

our $VERSION = '0.01';

use XML::Twig;
use Mojo::DOM58;

our $html = [];

sub new {
  my $class = shift;
  # uncoverable condition false
  bless @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}, ref $class || $class;
}

sub parse {
  my ($self, $XML) = @_;

  my $dom = Mojo::DOM58->new->parse($XML);

  my $twig = XML::Twig->new(
    #remove_cdata => 1,
    TwigHandlers => {
  	  '/html' => \&html,
    }
  );

  #eval { $twig->parse($XML); };
  eval { $twig->parse($dom->xml(1)->to_string); };

  if ($@) {
    #print STDERR "XML PARSE ERROR: " . $@;
    die "XML PARSE ERROR: " . $@;
  }

  return $html;
}

sub parsefile {
  my ($self, $XMLFILE) = @_;

  my $string;

{
  local $/=undef;
  open(my $xml_fh,"<:encoding(UTF-8)",$XMLFILE) or die "cannot open $XMLFILE: $!";
  $string = <$xml_fh>;
  close $xml_fh;
}

  my $dom = Mojo::DOM58->new->parse($string);

  my $twig = XML::Twig->new(
    #remove_cdata => 1,
    TwigHandlers => {
  	  '/html' => \&html,
    }
  );

  #eval { $twig->parsefile($XMLFILE); };
  eval { $twig->parse($dom->xml(1)->to_string); };

  if ($@) {
    #print STDERR "XML PARSE ERROR: " . $@;
    die "XML PARSE ERROR: " . $@;
  }

  return $html;
}

sub html {
  my ($t, $element) = @_;

  element($element,$html);
}

sub element {
  my ($element,$parent) = @_;

  my $element_entry = {
    'children' => [],
    'tag' => $element->tag,
  };

  my $attributes = $element->atts;
  for my $attribute (keys %{$attributes}) {
    if ($attribute eq 'title') {
      $element_entry->{'title'} = {};
      title($element_entry->{'title'},$element->{'att'}->{'title'});
    }
    elsif ($attribute eq 'class') {
      class($element_entry,$element->{'att'}->{'class'});
    }
    else {
      $element_entry->{$attribute} = $element->{'att'}->{$attribute};
    }
  }

  my @children = $element->children();
  for my $child (@children) {
    if ($child->tag eq '#PCDATA') {
      push @{$element_entry->{'children'}}, $child->text;
    }
    else {
      element($child,$element_entry->{'children'});
    }
  }
  push @{$parent},$element_entry;
}

sub title {
  my ($elem,$title) = @_;

  my @title_parts = split(m/[;,]\s+/,$title);

  for my $title_part (@title_parts) {
    my @strings = split(/\s+/,$title_part);
    if ($strings[0] eq 'image') {
      $elem->{'image'} = $strings[1];
    }
    elsif ($strings[0] eq 'ppageno') {
      $elem->{'ppageno'} = $strings[1];
    }
    elsif ($strings[0] eq 'bbox') {
      $elem->{'bbox'} = bbox(@strings);
    }
    elsif ($strings[0] eq 'baseline') {
      $elem->{'baseline'} = baseline(@strings);
    }
    elsif ($strings[0] eq 'x_wconf') {
      $elem->{'x_wconf'} = $strings[1];
    }
    # x_confs 0.335380083959 0.455066963347
    elsif ($strings[0] eq 'x_confs') {
      shift @strings;
      $elem->{'x_confs'} = [@strings];
    }
    # cuts 0,0,20,0 26,0,42,0
    elsif ($strings[0] eq 'cuts') {
      shift @strings;
      $elem->{'cuts'} = [@strings];
    }
    # x_bboxes 195 202 205 227 212 201 229 228
    elsif ($strings[0] eq 'x_bboxes') {
      shift @strings;
      $elem->{'x_bboxes'} = [@strings];
    }
    else {
      $elem->{$strings[0]} = $strings[1];
      #print STDERR 'unparsed property: ',$strings[0],' => ',$strings[1],"\n";
    }
  }

}

sub class {
  my ($elem,$class) = @_;

  $elem->{'class'} = $class;

}

sub baseline {
  return {
        'skew' => $_[1],
        'offset' => $_[2],
  };
}

sub bbox {
  return {
    'x1' => $_[1],
    'y1' => $_[2],
    'x2' => $_[3],
    'y2' => $_[4],
  };
}

sub _init {
  my $self = shift;

    my $p = $self->{pattern_parts};

    $p->{'digit'}    = qr/[0-9]/xms;
    $p->{'uint'}     = qr/$p->{'digit'}+/xms;
    $p->{'int'}      = qr/-? $p->{'uint'}/xms;
    $p->{'nint'}     = qr/- $p->{'uint'}/xms;
    $p->{'fraction'} = qr/\. $p->{'uint'}/xms;
    $p->{'float'}    = qr/$p->{'uint'}? fraction/xms;

    $p->{'whitespace'}       = qr/\ +/xms;
    $p->{'comma'}            = qr/,/xms;
    $p->{'semicolon'}        = qr/;/xms;
    $p->{'doublequote'}      = qr/"/xms;
    $p->{'lowercase-letter'} = qr/[a-z]/xms;
    $p->{'alnum-word'}       = qr/[$p->{'lowercase-letter'}$p->{'digit'}]+/xms;
    $p->{'ascii-word'}       = qr/[^\x00-\x20$p->{'semicolon'}$p->{'doublequote'}]+/xms;
    $p->{'ascii-string'}     = qr/[^$p->{'semicolon'}$p->{'doublequote'}]+/xms;
    $p->{'delimited-string'} = qr/
    	$p->{'doublequote'}
    	$p->{'ascii-string'}
    	$p->{'doublequote'}
    /xms;
    $p->{'spec-property-name'}    = qr/(
    	bbox
    	| baseline
    	| cflow
    	| cuts
    	| hardbreak
    	| image
    	| imagemd5
    	| lpageno
    	| nlp
    	| order
    	| poly
    	| ppageno
    	| scan_res
    	| textangle
    	| x_bboxes
    	| x_confs
    	| x_font
    	| x_fsize
    	| x_scanner
    	| x_source
    	| x_wconf
    )/xms;
    $p->{'engine-property-name'}  = qr/x_ $p->{'alnum-word'}/xms;
    $p->{'property-name'}         = qr/
    	$p->{'spec-property-name'}
    	| $p->{'engine-property-name'}
    /xms;
    $p->{'property-value'}        = qr/
    	$p->{'ascii-word'}
    	($p->{'whitespace'} $p->{'ascii-word'})*
    /xms;
    $p->{'key-value-pair'}        = qr/
    	$p->{'property-name'}
    	$p->{'whitespace'}
    	$p->{'property-value'}
    /xms;
    $p->{'properties-format'}     = qr/
    	$p->{'key-value-pair'}
    	(
    		$p->{'whitespace'}
    		$p->{'semicolon'}
    		$p->{'key-value-pair'}
    	)*
    /xms;

}



1;

__END__

=encoding utf-8

=head1 NAME

OCR::hOCR - Process hOCR

=begin html

<a href="https://travis-ci.org/wollmers/OCR-hOCR"><img src="https://travis-ci.org/wollmers/OCR-hOCR.png" alt="OCR-hOCR"></a>
<a href='https://coveralls.io/r/wollmers/OCR-hOCR?branch=master'><img src='https://coveralls.io/repos/wollmers/OCR-hOCR/badge.png?branch=master' alt='Coverage Status' /></a>
<a href='http://cpants.cpanauthors.org/dist/OCR-hOCR'><img src='http://cpants.cpanauthors.org/dist/OCR-hOCR.png' alt='Kwalitee Score' /></a>
<a href="http://badge.fury.io/pl/OCR-hOCR"><img src="https://badge.fury.io/pl/OCR-hOCR.svg" alt="CPAN version" height="18"></a>

=end html

=head1 SYNOPSIS

  use OCR::hOCR;


=head1 DESCRIPTION

OCR::hOCR parses and writes OCR files in the hOCR format.

=head2 CONSTRUCTOR

=over 4

=item new()

Creates a new object which maintains internal storage areas
for the OCR::hOCR computation.

=back

=head2 METHODS

=over 4


=item parse($text)

Parse ...


=back

=head2 EXPORT

None by design.

=head1 STABILITY

Until release of version 1.00 the included methods, names of methods and their
interfaces are subject to change.

Beginning with version 1.00 the specification will be stable, i.e. not changed between
major versions.


=head1 SOURCE REPOSITORY

L<http://github.com/wollmers/OCR-hOCR>

=head1 AUTHOR

Helmut Wollmersdorfer E<lt>helmut.wollmersdorfer@gmail.comE<gt>

=begin html

<a href='http://cpants.cpanauthors.org/author/wollmers'><img src='http://cpants.cpanauthors.org/author/wollmers.png' alt='Kwalitee Score' /></a>

=end html

=head1 COPYRIGHT

Copyright 2016 Helmut Wollmersdorfer

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO


=cut

