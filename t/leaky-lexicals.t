#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 8;

use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Lambda');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::Builder');
use_ok('Lorzy::FunctionArgument');

my $eval = Lorzy::Evaluator->new;
my $builder = Lorzy::Builder->new();

my $A_SIDE = Lorzy::Builder->defun(
        ops => [

         { name => 'Symbol', args => { symbol => 'x'}},
                    { name => 'Symbol', args => { symbol => 'y'} }


                ],
        signature => { x => Lorzy::FunctionArgument->new(name => 'x', type => 'Str')});


$eval->set_global_symbol( 'a' => $A_SIDE );

my $defined_b = $builder->defun(
    ops => [{ name => 'a', args => { x => 'x456' }} ],
    signature =>
        { y => Lorzy::FunctionArgument->new( name => 'y', type => 'String' ) }
);

$eval->set_global_symbol( b=> $defined_b);

$eval->run( $builder->build_expression( { name => 'b', args => { y => 'Y123' }}));
ok (!$eval->result->success);
like($eval->result->error,qr/Could not find symbol y in the current lexical context/);

diag $eval->result->error->stack_as_string;


