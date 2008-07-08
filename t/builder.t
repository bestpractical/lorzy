use Test::More tests => 4;
use strict;
use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();
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
                                       }, 'Lorzy::Expression::True' ),
                                bless( {
                                         'signature' => {},
                                         'name' => 'False',
                                         'args' => {}
                                       }, 'Lorzy::Expression::False' )
                              ]
                 }, 'Lorzy::Expression::ProgN' )

        ]                );
