#!/usr/bin/perl

use Test::More qw/no_plan/;
use_ok('PIE::Evaluator');
my $e = PIE::Evaluator->new();

my $signatures =  $e->builtin_signatures;
is_deeply($signatures->{'PIE::Expression::True'} , {});
is_deeply($signatures->{'PIE::Expression::IfThen'} , { if_true => { type => 'PIE::Evaluatable'},
                                                    if_false => {type => 'PIE::Evaluatable'},
                                                    condition => {type => 'PIE::Evaluatable'}
    
    
    });



