use Test::More tests => 26;
use strict;

use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Lambda');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::Builder');
use_ok('Lorzy::FunctionArgument');

my $trivial = Lorzy::Expression::True->new;

my $evaluator = Lorzy::Evaluator->new;
ok( $evaluator->run($trivial) );
ok( $evaluator->result->success );
ok( $evaluator->result->value );

my $false = Lorzy::Expression::False->new();
my $eval2 = Lorzy::Evaluator->new;
ok( $eval2->run($false) );
ok( !$eval2->result->value );
ok( $eval2->result->success );

my $if_true = Lorzy::Expression::IfThen->new( args => {
    condition => Lorzy::Expression::True->new(),
    if_true   => Lorzy::Expression::True->new(),
    if_false  => Lorzy::Expression::False->new()}
);

my $eval3 = Lorzy::Evaluator->new();
ok( $eval3->run($if_true) );
ok( $eval3->result->value );
ok( $eval3->result->success, $eval3->result->error );

my $if_false = Lorzy::Expression::IfThen->new( args => {
    condition => Lorzy::Expression::False->new(),
    if_true   => Lorzy::Expression::True->new(),
    if_false  => Lorzy::Expression::False->new()}
);

my $eval4 = Lorzy::Evaluator->new();
ok( $eval4->run($if_false) );
ok( !$eval4->result->value );
ok( $eval4->result->success );

my $script = Lorzy::Lambda->new(
   progn => Lorzy::Expression::ProgN->new(
    nodes => [
        Lorzy::Expression::True->new()

    ]),

);

my $eval7 = Lorzy::Evaluator->new();
$eval7->apply_script($script, {} );
ok( $eval7->result->success );
ok( $eval7->result->value );

my $script2 = Lorzy::Lambda->new(
   progn => Lorzy::Expression::ProgN->new(
 nodes => [$if_true] ) );

my $eval8 = Lorzy::Evaluator->new();
$eval8->apply_script($script2, {});
ok( $eval8->result->success );
ok( $eval8->result->value );

my $eval9 = Lorzy::Evaluator->new();

my $MATCH_REGEX = Lorzy::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg    = $args->{'tested-string'};
        my $regexp = $args->{'regexp'};
        return ($arg =~ m/$regexp/ )? 1 : 0;
    },

    signature => {
        'tested-string' => Lorzy::FunctionArgument->new( name => 'tested-string' => type => 'Str'),
        'regexp' => Lorzy::FunctionArgument->new( name => 'regexp', type => 'Str' )
        }

);

$eval9->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

$eval9->apply_script(
    $MATCH_REGEX, 
    {   'tested-string' => Lorzy::Expression::String->new( args => {value => 'I do love software'} ),
        'regexp' => Lorzy::Expression::String->new( args => { value => 'software' })
    }
);

ok( $eval9->result->success, $eval9->result->error );
is( $eval9->result->value, 1 );

my $builder = Lorzy::Builder->new();
my $eval10 = Lorzy::Evaluator->new();
$eval10->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

$eval10->apply_script(
    $builder->defun(
        ops => [
            {   name => 'IfThen',
                args => {
                    'if_true'   => 'hate',
                    'if_false'  => 'love',
                    'condition' => {
                        name => 'match-regexp',
                        args => {
                            regexp           => 'software',
                            'tested-string' => 'foo',
                        }
                    }
                }
            }
        ],
        signature => {},
    ),
    {},
);
ok( $eval10->result->success, " Did not get an error: ".$eval10->result->error );
is( $eval10->result->value, 'love' );

