#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;
use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::Lambda::Native');

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();

my $invoke_native = Lorzy::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $method = $args->{method};
        die "Invalid 'args' $args->{args}" unless ref($args->{args}) eq 'Lorzy::EvaluatorResult::RunTime';
        my $nodes = ${$args->{args}};

        $args->{obj}->$method( @$nodes );
    },

    signature => {
        'obj' => Lorzy::FunctionArgument->new( name => 'obj'),
        'method' => Lorzy::FunctionArgument->new( name => 'method', type => 'Str' ),
        'args' => Lorzy::FunctionArgument->new( name => 'args' ),
        }

);

$eval->set_global_symbol( 'invoke!' => $invoke_native );

my $script = $builder->defun(
                             ops => [
                                     { name => 'ProgN',
                                       args => {
                                                nodes => [
                                                          { name => 'invoke!', args => 
                                                            { obj => { name => 'Symbol', args => { symbol => 'something' } },
                                                              method => 'hello',
                                                              args => { name => 'List', nodes => [ 'orz' ] },
                                                                                     } },
                         ],
                                               } } ],
                            signature => { something => 
                                               Lorzy::FunctionArgument->new( name => 'tested-string')});

isa_ok($script, "Lorzy::Lambda");
my $ret;
lives_ok {
    $ret = $eval->apply_script( $script, { 'something' => bless {}, 'TestClass' } );
};
is($ret, 'world');

package TestClass;

sub hello {
    return 'world';
}
