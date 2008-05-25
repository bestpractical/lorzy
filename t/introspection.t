#!/usr/bin/perl

use Test::More qw/no_plan/;
use_ok('PIE::Evaluator');
use_ok('PIE::Lambda::Native');
my $e = PIE::Evaluator->new();

my $signatures =  $e->core_expression_signatures;
is_deeply($signatures->{'PIE::Expression::True'} , {});
is_deeply($signatures->{'PIE::Expression::IfThen'} , { if_true => { type => 'PIE::Evaluatable'},
                                                    if_false => {type => 'PIE::Evaluatable'},
                                                    condition => {type => 'PIE::Evaluatable'}
    
    
    });
my $symbols = $e->symbol_signatures();
is_deeply($symbols, {});

my $MATCH_REGEX = PIE::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg    = $args->{'tested-string'};
        my $regexp = $args->{'regexp'};
        return ($arg =~ m/$regexp/ )? 1 : 0;
    },

    signature => {
        'tested-string' => PIE::FunctionArgument->new( name => 'tested-string' => type => 'Str'),
        'regexp' => PIE::FunctionArgument->new( name => 'regexp', type => 'Str' )
        }

);

$e->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

$symbols = $e->symbol_signatures();
is_deeply($e->symbol_signatures(),  { 'match-regexp' => { regexp => { type => 'Str'}, 'tested-string' => { type => 'Str'}}});


