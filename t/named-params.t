use Test::More qw/no_plan/;
use_ok('PIE::Lambda');
use_ok('PIE::Lambda::Native');
use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::FunctionArgument');
my $MATCH_REGEX = PIE::Lambda::Native->new(
    body => sub {
        my %args = (@_);
        my $arg = $args{'tested-string'};
        my $regexp = $args{'regexp'};
            
        return $arg =~ m/$regexp/;
    },

    args => {
           'tested-string' =>  PIE::FunctionArgument->new( name =>              'tested-string' =>  type => 'Str' ),
           'regex'=>  PIE::FunctionArgument->new( name =>      'regex', type => 'Str' )
    }

);

my $eval5 = PIE::Evaluator->new;
$eval5->set_named( 'match-regexp' => $MATCH_REGEX );

my $match_p = PIE::Expression->new(
        name => 'match-regexp',
        args => {
            'tested-string' =>          PIE::Expression::String->new( value => 'I do love software' ),
            'regex' =>                  PIE::Expression::String->new( value => 'software' )
        }
);

$eval5->run($match_p);
ok( $eval5->result->success );

is( $eval5->result->value, 1 );

my $eval6 = PIE::Evaluator->new();

$eval6->set_named( 'match-regexp' => $MATCH_REGEX );

my $match_fail_p = PIE::Expression->new(
        name => 'match-regexp',
        args => { 
        'tested-string' => PIE::Expression::String->new( value => 'I do love hardware' ),
        'regexp' => PIE::Expression::String->new( value => 'software' )
}
);

$eval6->run($match_fail_p);
ok( !$eval6->result->success );

ok( !$eval6->result->value );


my $match_orz = PIE::Expression->new(
        name => 'match-regexp',
        args => {
            'tested-string' =>          PIE::Expression::String->new( value => 'I do love software' ),
            'wrong-regepx' =>            PIE::Expression::String->new( value => 'software' ),
        }
);

$eval6->run($match_orz);
ok( !$eval6->result->success );
