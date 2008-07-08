#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 4;

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

# XXX: ensure $script structure
is_deeply($script->progn->nodes,
        [
          bless( {
                   'signature' => {},
                   'name' => 'Lorzy::Expression::ProgN',
                   'args' => {},
                   'nodes' => [
                                bless( {
                                         'signature' => {},
                                         'name' => 'Lorzy::Expression::True',
                                         'args' => {}
                                       }, 'Lorzy::Expression::True' ),
                                bless( {
                                         'signature' => {},
                                         'name' => 'Lorzy::Expression::False',
                                         'args' => {}
                                       }, 'Lorzy::Expression::False' )
                              ]
                 }, 'Lorzy::Expression::ProgN' )

        ]                );
