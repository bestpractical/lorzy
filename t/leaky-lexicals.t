use Test::More qw'no_plan';
use strict;
use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Lambda');
use_ok('PIE::Lambda::Native');
use_ok('PIE::Builder');
use_ok('PIE::FunctionArgument');


my $eval = PIE::Evaluator->new;
my $builder = PIE::Builder->new();

my $A_SIDE = PIE::Builder->defun( 
        ops => [ 
        
         { name => 'Symbol', args => { symbol => 'x'}},
                    { name => 'Symbol', args => { symbol => 'y'} }
                
                
                ],
        signature => { x => PIE::FunctionArgument->new(name => 'x', type => 'Str')});


$eval->set_named( 'a' => $A_SIDE );

my $defined_b = $builder->defun(
    ops => [{ name => 'a', args => { x => 'x456' }} ],
    signature =>
        { y => PIE::FunctionArgument->new( name => 'y', type => 'String' ) }
);

$eval->set_named( b=> $defined_b);

$eval->run( $builder->build_expression( { name => 'b', args => { y => 'Y123' }}));
ok (!$eval->result->success);
like($eval->result->error,qr/Could not find symbol y in the current lexical context/);
