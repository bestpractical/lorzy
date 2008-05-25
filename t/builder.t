use Test::More qw'no_plan';
use strict;
use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Builder');

my $builder = PIE::Builder->new();
my $eval = PIE::Evaluator->new();
#$eval->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

my $script = $builder->defun(
                             ops => [
                                     { name => 'ProgN',
                                       args => {
                                                nodes => [
                                                          { name => 'True', args => {} },
                                                          { name => 'False', args => {} },
                         ],
                                               } } ],
                            signature => {});

#warn Dumper($script);use Data::Dumper;
# XXX: ensure $script structure
is(scalar @{$script->progn->nodes}, 1);
isa_ok($script->progn->nodes->[0], 'PIE::Expression::ProgN');
is(scalar @{$script->progn->nodes->[0]->nodes}, 2);

isa_ok($script->progn->nodes->[0]->nodes->[0], 'PIE::Expression::True');
isa_ok($script->progn->nodes->[0]->nodes->[1], 'PIE::Expression::False');
