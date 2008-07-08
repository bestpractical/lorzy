use Test::More tests => 10;
use warnings;
use strict;

use_ok('Lorzy::Lambda');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::FunctionArgument');
my $MATCH_REGEX = Lorzy::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg = $args->{'tested-string'};
        my $regex = $args->{'regex'};
            
        return $arg =~ m/$regex/;
    },

    signature => {
           'tested-string' =>  Lorzy::FunctionArgument->new( name =>              'tested-string' =>  type => 'Str' ),
           'regex'=>  Lorzy::FunctionArgument->new( name =>      'regex', type => 'Str' )
    }

);
my $eval5 = Lorzy::Evaluator->new;
$eval5->set_global_symbol( 'match-regex' => $MATCH_REGEX );

my $match_p = Lorzy::Expression->new(
        name => 'match-regex',
        args => {
            'tested-string' =>          Lorzy::Expression::String->new( args => {value => 'I do love software'} ),
            'regex' =>                  Lorzy::Expression::String->new( args => { value => 'software' } )
        }
);

$eval5->run($match_p);
ok( $eval5->result->success );

is( $eval5->result->value, 1 );

my $eval6 = Lorzy::Evaluator->new();

$eval6->set_global_symbol( 'match-regex' => $MATCH_REGEX );

my $match_fail_p = Lorzy::Expression->new(
        name => 'match-regex',
        args => { 
        'tested-string' => Lorzy::Expression::String->new( args => { value => 'I do love hardware' }),
        'regex' => Lorzy::Expression::String->new( args => { value => 'software'} )
}
);

$eval6->run($match_fail_p);
ok( $eval6->result->success );
ok( !$eval6->result->value );


my $match_orz = Lorzy::Expression->new(
        name => 'match-regex',
        args => {
            'tested-string' =>          Lorzy::Expression::String->new( args => { value => 'I do love software'} ),
            'wrong-param-name' =>            Lorzy::Expression::String->new( args => {  value => 'software' }),
        }
);

$eval6->run($match_orz);

ok( !$eval6->result->success, "yay! it failed when we gave it a wrong argument name". $eval6->result->error );
