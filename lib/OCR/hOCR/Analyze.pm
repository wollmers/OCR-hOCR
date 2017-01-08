package OCR::hOCR::Analyze;
use utf8;

use strict;
use warnings;

our $VERSION = '0.01';

use Data::Dumper;

binmode(STDOUT,":encoding(UTF-8)");
binmode(STDERR,":encoding(UTF-8)");

sub new {
  my $class = shift;
  # uncoverable condition false
  bless @_ ? @_ > 1 ? {@_} : {%{$_[0]}} : {}, ref $class || $class;
}

=pod

check_parent($careas,$pars);
check_parent($pars,$lines);
check_parent($lines,$words);

my $careas_x1 = cluster($careas,'x1');
print '$careas_x1: ',"\n";
print_grouping($careas_x1);

my $careas_x2 = cluster($careas,'x2');
print '$careas_x2: ',"\n";
print_grouping($careas_x2);

my $lines_x1 = cluster($lines,'x1');
print '$lines_x1: ',"\n";
print_grouping($lines_x1);

my $lines_x2 = cluster($lines,'x2');
print '$lines_x2: ',"\n";
print_grouping($lines_x2);

print 'col_estimation careas x1',"\n";
col_estimation($careas,'x1');

my $density_words_x = density($words,'x1','x2');
print '$density_words_x: ',"\n";

#for my $point (sort { $a <=> $b } keys %$density_words_x) {
#  print sprintf('%6s',$point),': ',sprintf('%6s',$density_words_x->{$point}),"\n";;
#}

my ($white_stripes_x,$black_stripes_x)
  = white_stripes($density_words_x,$pages->{'page_1'}->{'x1'},$pages->{'page_1'}->{'x2'});

print '$white_stripes_x: ',"\n";
print Dumper($white_stripes_x);
print '$black_stripes_x: ',"\n";
print Dumper($black_stripes_x);

sub white_stripes {
  my ($density,$x1,$x2) = @_;

  my $w_stripes = [];
  my $w_stripe_x1 = $x1;
  my $b_stripes = [];
  my $b_stripe_x1 = -1;
  my $b_stripe_x2 = -1;

  for my $pos (sort {$a <=> $b} keys %$density) {
    if ($w_stripe_x1 == $x1) {
      if ($pos > $w_stripe_x1) {
        push @$w_stripes, [$w_stripe_x1, $pos-1];
      }
        $w_stripe_x1 = -1;
        $b_stripe_x1 = $pos;
        $b_stripe_x2 = $pos;
    }
    elsif ($pos == $b_stripe_x2+1) {
      $b_stripe_x2 = $pos;
    }
    elsif ($pos > $b_stripe_x2+1){
      push @$w_stripes, [$b_stripe_x2+1, $pos-1];
      push @$b_stripes, [$b_stripe_x1, $b_stripe_x2];
      $w_stripe_x1 = -1;
      $b_stripe_x1 = $pos;
      $b_stripe_x2 = $pos;
    }
  }
  push @$b_stripes, [$b_stripe_x1, $b_stripe_x2];
  if ($b_stripe_x2 < $x2) {
    push @$w_stripes, [$b_stripe_x2+1, $x2];
  }
  return ($w_stripes,$b_stripes);
}

sub print_grouping {
  my ($grouping) = @_;

  for my $group (sort { $a <=> $b } keys %$grouping) {
    print $group,"\n";
    for my $pos (sort { $a <=> $b } keys %{$grouping->{$group}}) {
      print "\t",$pos,"\t",$grouping->{$group}->{$pos},"\n";
    }
  }
}



use Statistics::KernelEstimation;

sub col_estimation {
  my ($objects,$measure) = @_;

  my $positions = {};

  for my $id (keys %$objects) {
    $positions->{$objects->{$id}->{$measure}}++;
  }

	my $s = Statistics::KernelEstimation->new();
	#my $s = Statistics::KernelEstimation->new_box();

	for my $position (keys %$positions) {
		for ( 1 .. $positions->{$position}  ) {
  			$s->add_data( $position );
		}
	}

	my $bandwidth = $s->default_bandwidth();
	#my $bandwidth = $s->optimal_bandwidth_safe();
	my ( $min, $max ) = $s->extended_range();

	print 'Probability density function (PDF)', "\n";
	for(my $x=$min; $x<=$max; $x+=($max-$min)/100 ) {
  		print $x, "\t", $s->pdf( $x, $bandwidth ), "\t", $s->cdf( $x, $bandwidth ), "\n";
	}

	# Alternatively:
	print 'histogram: ', "\n";
	my @histo = $s->histogram( 10 );            # 10 bins
	for( @histo ) {
  		print $_->{pos}, "\t", $_->{cnt}, "\n";
	}

	#@cumul = $s->distribution_function();
	#for( @cumul ) {
  	#	print $_->{pos}, "\t", $_->{cnt}, "\n";
	#}
}

=cut

sub print_area {
  my ($self,$parsed,$page_id) = @_;

  my $page_node = $parsed->{'ids'}->{$page_id};
  my $area_nodes = [
    grep { $_->{'type'} eq 'ocr_carea'}
    @{$self->children($parsed,$page_id)}
  ];

  $self->{'print_area'} = _envelope($area_nodes);

  return $self->{'print_area'};
}

# ocr_header
# ocr_footer
# ocr_pageno
# ocr_textfloat

sub float_areas {
  my ($self,$parsed,$page_id) = @_;

  my $column_sizes = $self->columns($parsed,$page_id);

  for my $col_num (1..10) {
    if ( exists $column_sizes->{$col_num} ) {
      my $column_envelopes = {};
      for (my $col = 0; $col < $col_num; $col++) {
        my $column_envelope = _envelope($column_sizes->{$col_num}->{$col});
        $column_envelopes->{$col} = $column_envelope if (scalar keys %{$column_envelope});
      #}
      #if (scalar keys %{$column_envelopes} == $col_num && $col_num < 10) {
      if (scalar keys %{$column_envelopes}) {
        for my $col_num2 ($col_num+1 .. 10) {
          for (my $col2 = 0; $col2 < $col_num2; $col2++) {
            for (0 .. $#{$column_sizes->{$col_num2}->{$col2}}) {
              if (exists $column_sizes->{$col_num2}->{$col2}
                && contains($column_envelope,$column_sizes->{$col_num2}->{$col2}->[$_])) {
                push @{$column_sizes->{$col_num}->{$col}},$column_sizes->{$col_num2}->{$col2}->[$_];
                delete $column_sizes->{$col_num2}->{$col2}->[$_];
              }
            }
          }
        }
      }

      }
    }

  }
  return $column_sizes;
}

sub columns {
  my ($self,$parsed,$page_id) = @_;

  my $page_node = $parsed->{'ids'}->{$page_id};
  my $area_nodes = [
    grep { $_->{'type'} eq 'ocr_carea'}
    @{$self->children($parsed,$page_id)}
  ];

  #print Dumper($area_nodes);
  my $print_area = $self->print_area($parsed,$page_id);

  my $print_width = abs($print_area->{'r'} - $print_area->{'l'});

  my $column_sizes = {};
  my $max_columns = 10;
  for my $area (@{$area_nodes}) {
    my $width = abs($area->{'r'} - $area->{'l'});
    for (my $i=1;$i < $max_columns;$i++) {
      my $max = int ($print_width/$i);
      my $min = int ($print_width/($i + 1));
      if ($width <= $max && $width > $min) {
        my $col = int (($area->{'l'} - $print_area->{'l'})/$max);
        push @{$column_sizes->{$i}->{$col}}, {
            'id' => $area->{'id'},
            'l' => $area->{'l'},
            'r' => $area->{'r'},
            't' => $area->{'t'},
            'b' => $area->{'b'},
          };
      }
    }
        my $max = int ($print_width/$max_columns);
        my $col = int (($area->{'l'} - $print_area->{'l'})/$max);
        push @{$column_sizes->{$max_columns}->{$col}}, {
            'id' => $area->{'id'},
            'l' => $area->{'l'},
            'r' => $area->{'r'},
            't' => $area->{'t'},
            'b' => $area->{'b'},
          };
  }
  return $column_sizes;
}

sub _envelope {
  my ($nodes) = @_;

  my $envelope = {};

    for my $node (@{$nodes}) {
    $envelope->{'l'} = min_def($envelope->{'l'},$node->{'l'});
    $envelope->{'t'} = min_def($envelope->{'t'},$node->{'t'});
    $envelope->{'r'} = max_def($envelope->{'r'},$node->{'r'});
    $envelope->{'b'} = max_def($envelope->{'b'},$node->{'b'});
  }
  return $envelope;
}

sub para_style {
  my ($self,$parsed,$para_id) = @_;

  my $para_node = $parsed->{'ids'}->{$para_id};
  my $line_nodes = [
    grep { $_->{'type'} eq 'ocr_line'}
    @{$self->children($parsed,$para_id)}
  ];
  return _para_style($para_node,$line_nodes);
}

my $all_styles = {
    '1' => {
      'block' => {
      'first_no_gap' => 1,
      },
      'intended' => {
      'first_left' => 1,
      'first_unsymmetric' => 1,
      },
      'centered' => {
      'first_symmetric' => 1,
      'first_no_gap' => 0.1,
      },
      'right_aligned' => {
      'first_left' => 1,
      },
      'left_aligned' => {
      'first_right' => 1,
      },
    },
    '2' => {
      'block' => {
        'first_no_gap' => 1,
        'last_no_gap' => 1,
      },
      'intended' => {
        'first_left' => 1,
        'last_right' => 1,
        'last_no_gap' => 0.1,
        'first_unsymmetric' => 1,
      },
      'centered' => {
        'first_symmetric' => 1,
        'last_symmetric' => 1,
        'first_no_gap' => 0.1,
        'last_no_gap' => 0.1,
      },
        'right_aligned' => {
        'first_left' => 1,
        'middle_left' => 1,
        'last_left' => 1,
      },
        'left_aligned' => {
        'first_right' => 1,
        'middle_right' => 1,
        'last_right' => 1,
      },
    },
    '3' => {
      'block' => {
        'first_no_gap' => 1,
        'middle_no_gap' => 1,
        'last_no_gap' => 1,
      },
      'intended' => {
        'first_left' => 1,
        'middle_no_gap' => 1,
        'last_right' => 1,
        'last_no_gap' => 0.1,
        'first_unsymmetric' => 1,
      },
      'centered' => {
        'first_symmetric' => 1,
        'middle_symmetric' => 1,
        'last_symmetric' => 1,
        'first_no_gap' => 0.1,
        'middle_no_gap' => 0.1,
        'last_no_gap' => 0.1,
      },
        'right_aligned' => {
        'first_left' => 1,
        'middle_left' => 1,
        'last_left' => 1,
      },
        'left_aligned' => {
        'first_right' => 1,
        'middle_right' => 1,
        'last_right' => 1,
      },
    },
  };

use Bag::Similarity::Dice;
#use Set::Similarity::Dice;
sub _para_style {
  my ($para_node,$line_nodes) = @_;

  my $line_gaps = line_gaps($para_node,$line_nodes);
  #print Dumper($line_gaps);

  my $styles =  $all_styles->{min(scalar(@{$line_nodes}),3)};
  my $scores = {};
  for my $style (keys %{$styles}) {
    $scores->{$style} =
      Bag::Similarity::Dice->similarity($line_gaps,$styles->{$style});
      #Set::Similarity::Dice->similarity($line_gaps,$styles->{$style})
  }
  #print Dumper($scores);
  my $sorted_scores = [ sort {$scores->{$b} <=> $scores->{$a}} keys %{$scores} ];
  my $highest_score = $scores->{$sorted_scores->[0]};
  my $highest_scores = {
    map { $_ => $scores->{$_} }
    grep { $scores->{$_} >= ($highest_score - 0.05) }
    keys %{$scores}
  };
  return $highest_scores;
}

sub line_gaps {
  my ($para_node,$line_nodes) = @_;

  my $gaps = {
    #'first_right' => 0,
    #'first_left' => 0,
    #'first_no_gap' => 0,
    #'first_symmetric' => 0,
    #'middle_right' => 0,
    #'middle_left' => 0,
    #'middle_no_gap' => 0,
    #'middle_symmetric' => 0,
    #'last_right' => 0,
    #'last_left' => 0,
    #'last_no_gap' => 0,
    #'last_symmetric' => 0,
  };

  return $gaps unless (@{$line_nodes});

  $gaps->{'first_'.line_gap($para_node,$line_nodes->[0])}++;

  return $gaps unless (@{$line_nodes} > 1);

  $gaps->{'last_'.line_gap($para_node,$line_nodes->[-1])}++;

  return $gaps unless (@$line_nodes > 2);

  for (my $i=1; $i < $#$line_nodes; $i++) {
    $gaps->{'middle_'.line_gap($para_node,$line_nodes->[$i])} += (1/(@$line_nodes-2));
  }
  return $gaps;
}


sub line_gap {
  my ($para_node,$line_node) = @_;

  #my $left_gap  = left_gap($para_node,$line_node);
  my $left_gap  = abs($line_node->{'l'} - $para_node->{'l'});
  #my $right_gap = right_gap($para_node,$line_node);
  my $right_gap = abs($line_node->{'r'} - $para_node->{'r'});
  my $threshold = abs($line_node->{'b'} - $line_node->{'t'});
  #print '$left_gap: ',$left_gap,' $right_gap: ',$right_gap,' $threshold: ',$threshold, "\n";

  if (
    $left_gap > $threshold
    && $right_gap > $threshold
    && abs($left_gap - $right_gap) < $threshold
  ) { return 'symmetric'; }
  elsif ($left_gap >  $threshold && $right_gap <= $threshold) { return 'left'; }
  elsif ($left_gap <= $threshold && $right_gap >  $threshold) { return 'right'; }
  elsif ($left_gap <= $threshold && $right_gap <= $threshold) { return 'no_gap'; }
  else { return 'unsymmetric'; }
}

sub line_spacing {
  my $line_node = shift;

  my $height = abs($line_node->{'b'} - $line_node->{'t'});
  my $word_nodes = [
    grep { $_->{'type'} eq 'ocrx_word'}
    @{$line_node->{'children'}}
  ];

  my $spaces = {};
  my $spaces_sum = 0;
  my $spaces_count = 0;
  for (my $i=0; $i < $#$word_nodes; $i++) {
    my $space = 0;
    if ($word_nodes->[$i]->{'r'} < $word_nodes->[$i+1]->{'l'}) {
      my $space = $word_nodes->[$i+1]->{'l'} - $word_nodes->[$i]->{'r'};
    }
    my $space_relative = sprintf('%0.1f',($space/$height));
    $spaces->{$space_relative}++;
    $spaces_sum += $space_relative;
    $spaces_count++;
  }
  my $spaces_average = ($spaces_count > 0) ? $spaces_sum/$spaces_count : 0;
  return $spaces_average;
}

sub left_gap {
  #my ($para_node,$line_node) = @_;

  _gap(@_,'l')
}

sub right_gap {
  #my ($para_node,$line_node) = @_;

  _gap(@_,'r')
}

sub _gap {
  #my ($para_node,$line_node,$edge) = @_;

  #return abs($line_node->{$edge} - $para_node->{$edge});
  abs($_[1]->{$_[2]} - $_[0]->{$_[2]});
}

sub children {
  my ($self,$parsed,$parent_id) = @_;

  return $parsed->{'ids'}->{$parent_id}->{'children'};
}

sub check_parent {
  my ($self,$parsed,$parent_type,$child_type) = @_;

  my $types = $parsed->{'type'};

  for my $child_id (@{$types->{$child_type}}) {
    my $child_node = $parsed->{'ids'}->{$child_id};
  	my $parent_count;
  	for my $parent_id (@{$types->{$parent_type}}) {
  	  my $parent_node = $parsed->{'ids'}->{$parent_id};
      if (contains($parent_node,$child_node)) {
      	$parent_count++;
      }
      if (overlap($parent_node,$child_node) && !contains($parent_node,$child_node)) {
      	  print 'overlaps: ',$parent_id,' ',$child_id,"\n";
      	  print '   l: ',$parent_node->{'l'},' ',$child_node->{'l'},"\n";
      	  print '   r: ',$parent_node->{'r'},' ',$child_node->{'r'},"\n";
      	  print '   t: ',$parent_node->{'t'},' ',$child_node->{'t'},"\n";
      	  print '   b: ',$parent_node->{'b'},' ',$child_node->{'b'},"\n";
      }
    }
  	if (!$parent_count){
      print 'child without parent: ',$child_id,"\n";
      for my $parent_id (@{$types->{$parent_type}}) {
        my $parent_node = $parsed->{'ids'}->{$parent_id};
    	if (overlap($parent_node,$child_node)) {
      	  print 'overlaps parent: ',$parent_id,' child: ',$child_id,"\n";
    	}
  	  }
    }
  }
}

sub print_stats {
  my ($self) = @_;

  for my $type (sort keys %{$self->{'stats'}}) {
    my $stat = $self->{'stats'}->{$type};
    print "\n";
    print sprintf('%9s',$type),': ';
	for my $val (qw(count min max mean deviation mode median)) {
	  print sprintf('%9s',$val),' ';
	}
	print "\n";

	FACT: for my $f (qw(t b l r height width skew offset x_wconf)) {
	  next FACT unless (exists $stat->{$f});
	  print sprintf('%9s',$f),': ';
	  for my $val (qw(count min max mean deviation mode median)) {
	    if (exists $stat->{$f}->{$val}) {
	      if ($stat->{$f}->{$val} > -1 && $stat->{$f}->{$val} < 1) {
	        print sprintf('%9s',sprintf('%0.3f',$stat->{$f}->{$val})),' ';
	      }
	      else {
	  	    print sprintf('%9s',sprintf('%0.0f',$stat->{$f}->{$val})),' ';
	  	  }
	    }
	    else {
	  	  print sprintf('%9s','na'),' ';
	    }
	  }
	  print "\n";
	}
  }
}

sub print_frequency {
  my ($self, $type, $fact) = @_;

  my $frequency = $self->{'stats'}->{$type}->{$fact}->{'frequency'};

  print "\n";
  print 'frequency for ',$type,' - ',$fact,"\n";

  for my $x (sort {$a <=> $b} keys %$frequency) {
    print sprintf('%4s',sprintf('%0.0f',$x)),' : ';
    print '*'x$frequency->{$x},"\n";
  }
}

sub stats {
  my ($self,$parsed) = @_;
  my $types = $parsed->{'type'};
  #print $types,': ',Dumper($types);
  for my $type (keys %{$types}) {
    $self->{'stats'}->{$type} = {};
    my $stat = $self->{'stats'}->{$type};
	for my $id (@{$types->{$type}}) {
	  my $node = $parsed->{'ids'}->{$id};

	  FACT: for my $f (qw(t b l r height width skew offset x_wconf)) {
	    next FACT unless (exists $node->{$f} || $f eq 'height' || $f eq 'width');
	    my $val;
	    if ($f eq 'width' && exists $node->{'r'} && exists $node->{'l'}) {
	      $val = $node->{'r'} - $node->{'l'};
	    }
	    elsif ($f eq 'height' && exists $node->{'b'} && exists $node->{'t'}) {
	      $val = $node->{'b'} - $node->{'t'};
	    }
	    else { $val = $node->{$f}; }

	  	#$node->{width} = $node->{r} - $node->{l};
        #$node->{height} = $node->{b} - $node->{t};
	  	$stat->{$f}->{'min'} = min_def($stat->{$f}->{'min'}, $val);
	  	$stat->{$f}->{'max'} = max_def($stat->{$f}->{'max'}, $val);
	  	$stat->{$f}->{'count'}++;
	  	$stat->{$f}->{'sum'} += $val;
	  	$stat->{$f}->{'quadsum'} += $val**2;
	  	$stat->{$f}->{'frequency'}->{$val}++;
	  }
	}
	#print Dumper($stat);
	FACT2: for my $f (qw(t b l r height width skew offset x_wconf)) {
	  next FACT2 unless (exists $stat->{$f});
	  if ($stat->{$f}->{'count'}) {
	    $stat->{$f}->{'mean'} = $stat->{$f}->{'sum'} / $stat->{$f}->{'count'};

	    $stat->{$f}->{'deviation'}
	      = sqrt(
	    	($stat->{$f}->{'quadsum'} / $stat->{$f}->{'count'}) - ($stat->{$f}->{'mean'}**2)
	      );
	      $stat->{$f}->{'mode'} = mode($stat->{$f}->{'frequency'});
	      $stat->{$f}->{'median'} = median($stat->{$f}->{'frequency'});
	  }
	  else {
	    $stat->{$f}->{'mean'} = 0;
	    $stat->{$f}->{'deviation'} = 0;
	    $stat->{$f}->{'mode'} = 0;
	    $stat->{$f}->{'median'} = 0;
	  }
	}
  }
}

sub mean {
	my ($x_n) = @_;

	my $sum_n;
	my $sum;
	for my $x (keys %$x_n) {
	  $sum += $x_n->{$x} * $x;
	  $sum_n += $x_n->{$x};
	}
	return $sum/$sum_n;
}

sub median {
	my ($x_n) = @_;

    my $flat = [];

	for my $x (sort {$a <=> $b} keys %$x_n) {
	  for (1..$x_n->{$x}) {
	    push @$flat,$x;
	  }
	}
	if (scalar(@$flat) == 0) { return undef }
	if (scalar(@$flat) % 2) {
	  return $flat->[int(scalar(@$flat) / 2)];
	}
	else {
	  my $first = int(scalar(@$flat) / 2);
	  my $avg = ($flat->[$first-1] + $flat->[$first]) / 2;
	  return $avg;
	}
}

sub mode {
	my ($x_n) = @_;

	return [sort { $x_n->{$b} <=> $x_n->{$a} } (keys %$x_n)]->[0];
}

sub histogram {
  my ($objects,$measure) = @_;

  my $x_n = {};

  for my $id (keys %$objects) {
    $x_n->{$objects->{$id}->{$measure}}++;
  }
  return $x_n;
}

sub deviation {
	my ($x_n) = @_;

    my $mean = mean($x_n);

	my $sum_n;
	my $sum;
	for my $x (keys %$x_n) {
	  $sum += $x_n->{$x} * (($x - $mean)**2);
	  $sum_n += $x_n->{$x};
	}
	return sqrt($sum/$sum_n);
}

# https://en.wikipedia.org/wiki/OPTICS_algorithm

=pod

 OPTICS(DB, eps, MinPts)
    for each point p of DB
       p.reachability-distance = UNDEFINED
    for each unprocessed point p of DB
       N = getNeighbors(p, eps)
       mark p as processed
       output p to the ordered list
       if (core-distance(p, eps, Minpts) != UNDEFINED)
          Seeds = empty priority queue
          update(N, p, Seeds, eps, Minpts)
          for each next q in Seeds
             N' = getNeighbors(q, eps)
             mark q as processed
             output q to the ordered list
             if (core-distance(q, eps, Minpts) != UNDEFINED)
                update(N', q, Seeds, eps, Minpts)

 update(N, p, Seeds, eps, Minpts)
    coredist = core-distance(p, eps, MinPts)
    for each o in N
       if (o is not processed)
          new-reach-dist = max(coredist, dist(p,o))
          if (o.reachability-distance == UNDEFINED) // o is not in Seeds
              o.reachability-distance = new-reach-dist
              Seeds.insert(o, new-reach-dist)
          else               // o in Seeds, check for improvement
              if (new-reach-dist < o.reachability-distance)
                 o.reachability-distance = new-reach-dist
                 Seeds.move-up(o, new-reach-dist)

=cut

=pod

sub cluster {
  my ($objects,$measure) = @_;

  my $positions = {};

  for my $id (keys %$objects) {
    $positions->{$objects->{$id}->{$measure}}++;
  }

  my $grouping = {};

  my $delta = 8;

  my $pos1 = 0;
  my $poslast = 0;
  for my $pos (sort { $a <=> $b } keys %$positions) {
    if ($poslast + $delta > $pos) {
      $poslast = $pos;
      $grouping->{$pos1}->{$pos} = $positions->{$pos};
    }
    else {
      $pos1 = $pos;
      $poslast = $pos;
      $grouping->{$pos1}->{$pos} = $positions->{$pos};
    }
  }
  return $grouping;
}

sub density {
  my ($objects,$measure1,$measure2) = @_;

  my $density = {};

  for my $id (keys %$objects) {
    for my $point ($objects->{$id}->{$measure1} .. $objects->{$id}->{$measure2}) {
      $density->{$point}++;
    }
  }

  return $density;
}

=cut

# u contains v
# 1 if overlap
sub contains {
  my ($u, $v) = @_;
  return (
  		$u->{'l'} <= $v->{'l'}
  	&&  $u->{'r'} >= $v->{'r'}
    &&  $u->{'t'} <= $v->{'t'}
    &&  $u->{'b'} >= $v->{'b'}
  );
}

# > 0 if overlap (including line)
sub overlap {
  my ($u, $v) = @_;
  my $x1 = max($u->{'l'},$v->{'l'});
  my $x2 = min($u->{'r'},$v->{'r'});
  my $y1 = max($u->{'t'},$v->{'t'});
  my $y2 = min($u->{'b'},$v->{'b'});
  return area($x1,$x2+1,$y1,$y2+1);
}

sub area {
  my ($x1,$x2,$y1,$y2) = @_;
  return max(0,$x2-$x1) * max(0,$y2-$y1);
}



sub max { ($_[0] > $_[1]) ? $_[0] : $_[1] }
sub min { ($_[0] < $_[1]) ? $_[0] : $_[1] }
sub max_def {
    return $_[1] unless (defined $_[0]);
    return $_[0] unless (defined $_[1]);
	return ($_[0] > $_[1]) ? $_[0] : $_[1];
}
sub min_def {
    return $_[1] unless (defined $_[0]);
    return $_[0] unless (defined $_[1]);
	return  ($_[0] < $_[1]) ? $_[0] : $_[1];
}

1;
