#!perl
use utf8;

use strict;
use warnings;


use Mojo::DOM58;
use Data::Dumper;
use Mojo::DOM;

if (0) {
  my $dom = Mojo::DOM58->new->parse('<p>foo<br>bar &amp;</p>');

  my $parent = $dom->at('p');
  print '$parent->text: ',"'",$parent->text,"'","\n";
  my $children = $parent->child_nodes;
  for my $child (@{$children}) {
    if ($child->type eq 'text' || $child->type eq 'raw' || $child->type eq 'cdata' ) {
      print '$child->text: ',"'",$child->text,"'","\n";
      print '$child->tree->[1]: ',"'",$child->tree->[1],"'","\n";
      print '$child->to_string: ',"'",$child->to_string,"'","\n";
      # sub text { _text([_nodes(shift->tree)], 0) }
      print '_nodes($child->tree): ',"'",$child->_nodes($child->tree),"'","\n";
    }
    elsif ($child->type eq 'tag') {
      print '$child->tag: ',$child->tag,"\n";
    }
  }
}

{
  my $dom = Mojo::DOM->new->parse('<!-- &amp; -->');
  print '$dom->tree: ',"'",Dumper($dom->tree),"'","\n";
  print '$dom->tree->[0]: ',"'",Dumper($dom->tree->[0]),"'","\n";

  my $parent = $dom->root;
  #my $parent = $dom->at('p');
  print '$parent->text: ',"'",$parent->text,"'","\n";
  print '$parent->tree: ',"'",Dumper($parent->tree),"'","\n";
  my $children = $parent->child_nodes();
  for my $child (@{$children}) {
    if ($child->type eq 'text' || $child->type eq 'raw' || $child->type eq 'cdata' || $child->type eq 'comment') {
      print '$child->text: ',"'",$child->text,"'","\n";           # empty string
      print '$child->tree->[1]: ',"'",$child->tree->[1],"'","\n"; # work-around
      print '$child->to_string: ',"'",$child->to_string,"'","\n"; # entity-encoded
      print '"$child": ',"'","$child","'","\n";
      # sub text { _text([_nodes(shift->tree)], 0) }
      print 'Mojo::DOM::_nodes($child->tree): ',"'",Dumper([Mojo::DOM::_nodes($child->tree)]),"'","\n";
      print '$child->tree: ',"'",Dumper($child->tree),"'","\n";
      #print '$child->child_nodes->first->type: ',"'",$child->child_nodes->first->type,"'","\n";

    }
    elsif ($child->type eq 'tag') {
      print '$child->tag: ',"'",$child->tag,"'","\n";
    }
  }
}

