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
use Data::Dumper;
is_deeply($script->progn->nodes, 
        [ 
          bless( {
                   'signature' => {},
                   'name' => 'ProgN',
                   'args' => {},
                   'nodes' => [
                                bless( {
                                         'signature' => {},
                                         'name' => 'True',
                                         'args' => {}
                                       }, 'PIE::Expression::True' ),
                                bless( {
                                         'signature' => {},
                                         'name' => 'False',
                                         'args' => {}
                                       }, 'PIE::Expression::False' )
                              ]
                 }, 'PIE::Expression::ProgN' )

        ]                );
