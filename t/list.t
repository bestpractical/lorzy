#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 6;
use Test::Exception;

use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::FunctionArgument');

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();

my $script =
    $builder->defun(
    ops => [
        { name => 'List',
            args => {
                nodes => [
                     "hate",
                     "love",
                     "hate"  ] } } ],
    signature => { });

$eval->set_global_symbol( 'get-list' => $script );

my @remembered;
$eval->set_global_symbol( 'remember' =>
Lorzy::Lambda::Native->new(
    body => sub {
        my $args = shift;
        push @remembered, $args->{what};
        return 1;
    },

    signature => {
        'what' => Lorzy::FunctionArgument->new( name => 'what' => type => 'Str'),
        }

) );


$eval->apply_script(
    $builder->defun(
    ops => [
        { name => 'ForEach',
            args => {
                list => { name => 'get-list', args => {} },
                binding => 'what',
                do => { name => 'Symbol', args => { symbol => 'remember'} }
                    }
        } ],
    signature => { }),
 {});

is_deeply(\@remembered, ['hate', 'love', 'hate']);
