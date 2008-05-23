use Test::More qw'no_plan';

use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Lambda');
use_ok('PIE::Lambda::Native');
use_ok('PIE::Builder');
use_ok('PIE::FunctionArgument');
my $trivial = PIE::Expression::True->new;

my $evaluator = PIE::Evaluator->new;
ok( $evaluator->run($trivial) );
ok( $evaluator->result->success );
ok( $evaluator->result->value );

my $false = PIE::Expression::False->new();
my $eval2 = PIE::Evaluator->new;
ok( $eval2->run($false) );
ok( !$eval2->result->value );
ok( $eval2->result->success );

my $if_true = PIE::Expression::IfThen->new(
    condition => PIE::Expression::True->new(),
    if_true   => PIE::Expression::True->new(),
    if_false  => PIE::Expression::False->new()
);

my $eval3 = PIE::Evaluator->new();
ok( $eval3->run($if_true) );
ok( $eval3->result->value );
ok( $eval2->result->success );

my $if_false = PIE::Expression::IfThen->new(
    condition => PIE::Expression::False->new(),
    if_true   => PIE::Expression::True->new(),
    if_false  => PIE::Expression::False->new()
);

my $eval4 = PIE::Evaluator->new();
ok( $eval4->run($if_false) );
ok( !$eval4->result->value );
ok( $eval4->result->success );

my $script = PIE::Lambda->new(
    nodes => [
        PIE::Expression::True->new()

    ],

);

my $eval7 = PIE::Evaluator->new();
$eval7->apply_script($script, {} );
ok( $eval7->result->success );
ok( $eval7->result->value );

my $script2 = PIE::Lambda->new( nodes => [$if_true] );

my $eval8 = PIE::Evaluator->new();
$eval8->apply_script($script2, {});
ok( $eval8->result->success );
ok( $eval8->result->value );

my $eval9 = PIE::Evaluator->new();

my $MATCH_REGEX = PIE::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg    = $args->{'tested-string'};
        my $regexp = $args->{'regexp'};

        return ($arg =~ m/$regexp/ )? 1 : 0;
    },

    signature => {
        'tested-string' => PIE::FunctionArgument->new( name => 'tested-string' => type => 'Str'),
        'regex' => PIE::FunctionArgument->new( name => 'regex', type => 'Str' )
        }

);

$eval9->set_named( 'match-regexp' => $MATCH_REGEX );
$eval9->apply_script(
    $MATCH_REGEX, 
    {   'tested-string' => PIE::Expression::String->new( value => 'I do love software' ),
        'regex' => PIE::Expression::String->new( value => 'software' )
    }
);

ok( $eval9->result->success );
is( $eval9->result->value, 1 );

my $builder = PIE::Builder->new();
my $eval10 = PIE::Evaluator->new();
$eval10->set_named( 'match-regexp' => $MATCH_REGEX );

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
                            regex           => 'software',
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

