#!/usr/bin/perl

use Test::More qw/no_plan/;
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Lambda::Native');
my $e = Lorzy::Evaluator->new();

my $signatures =  $e->core_expression_signatures;
is_deeply($signatures->{'Lorzy::Expression::True'} , {});
is_deeply($signatures->{'Lorzy::Expression::IfThen'} , { if_true => { type => 'Lorzy::Evaluatable'},
                                                    if_false => {type => 'Lorzy::Evaluatable'},
                                                    condition => {type => 'Lorzy::Evaluatable'}
    
    
    });
my $symbols = $e->symbol_signatures();
is_deeply($symbols, {});

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

$e->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

$symbols = $e->symbol_signatures();
is_deeply($e->symbol_signatures(),  { 'match-regexp' => { regexp => { type => 'Str'}, 'tested-string' => { type => 'Str'}}});


