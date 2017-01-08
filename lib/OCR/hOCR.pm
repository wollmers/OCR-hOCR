package OCR::hOCR;
use utf8;

use strict;
use warnings;

our $VERSION = '0.01';

use Mojo::DOM58;

sub new {
  my $class = shift;
  # uncoverable condition false
  bless @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}, ref $class || $class;
}

sub parse {
  my ($self, $XML) = @_;

  my $dom = Mojo::DOM58->new->parse($XML);

  #TODO:
  #$self->{'doctype'} = $dom->at('doctype');

  $self->{'tree'} = [];

  $self->html($dom->at('html'));

  return $self->{'tree'};
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

  return $self->parse($string);
}

sub html {
  my ($self, $element) = @_;

  $self->element($element,$self->{'tree'});
}

sub element {
  my ($self,$element,$parent) = @_;

  my $element_entry = {
    'children' => [],
    'tag' => ($element->type eq 'tag') ? $element->tag : $element->type,
  };

  my $attributes = $element->attr;
  for my $attribute (keys %{$attributes}) {
    if ($attribute eq 'title') {
      #$element_entry->{'title'} = {};
      #title($element_entry->{'title'},$attributes->{'title'});
      title($element_entry,$attributes->{'title'});
    }
    elsif ($attribute eq 'class') {
      class($element_entry,$attributes->{'class'});
    }
    else {
      $element_entry->{$attribute} = $attributes->{$attribute};
    }
  }

  my $children = $element->child_nodes();
  for my $child (@{$children}) {
    if ($child->type eq 'text' || $child->type eq 'raw' || $child->type eq 'cdata' ) {
      push @{$element_entry->{'children'}}, $child->tree->[1]
        unless ($child->tree->[1] =~ m/^\s*\n\s*$/);
    }
    else {
      $self->element($child,$element_entry->{'children'});
    }
  }
  push @{$parent},$element_entry;
}

sub index {
  my $self = shift;
  my $nodes = @_ ? shift : $self->{'tree'};
  return unless @{$nodes};

  for my $node (@{$nodes}) {
    next unless (ref $node);
    if (exists $node->{'id'}) {
      $self->{'ids'}->{$node->{'id'}} = $node;
      #if (exists $node->{'type'}) {
      #  push @{$self->{'types'}->{$node->{'type'}}},$node->{'id'};
      #}
      for my $key (qw(t b l r type)) {
        if (exists $node->{$key}) {
          push @{$self->{$key}->{$node->{$key}}},$node->{'id'};
        }
      }
    }
    $self->index($node->{'children'}) if (exists $node->{'children'});
  }
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
      #$elem->{'bbox'} = bbox(@strings);
      my $bbox = bbox(@strings);
      @{$elem}{keys %{$bbox}} = values %{$bbox};
    }
    elsif ($strings[0] eq 'baseline') {
      #$elem->{'baseline'} = baseline(@strings);
      my $baseline = baseline(@strings);
      @{$elem}{keys %{$baseline}} = values %{$baseline};
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

  my @parts = split(m/\s+/,$class);
  for my $part (@parts) {
    if ($part =~ m/^ocr/i) {
      $elem->{'type'} = lc($part);
    }
    else {
      push @{$elem->{'class'}}, lc($part);
    }
  }
}

sub baseline {
  return {
    'skew' => $_[1],
    'offset' => $_[2],
  };
}

sub bbox {
  return {
    'l' => $_[1],
    't' => $_[2],
    'r' => $_[3],
    'b' => $_[4],
  };
}

sub pattern_parts {
  my $self = shift;

  if (exists $self->{pattern_parts}) {
    return $self->{pattern_parts};
  }
  else {
    return $self->_init;
  }
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
    return $self->{pattern_parts};
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

