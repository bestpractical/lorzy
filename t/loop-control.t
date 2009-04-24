#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;

use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::FunctionArgument');

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();
$eval->load_package('Str');
my $script =
    $builder->defun(
    ops => [
        { name => 'List',
            args => {
                nodes => [ 1..10 ] } } ],
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


my $loop_code = $builder->defun(
    ops => [
        {   name => 'IfThen',
            args => {
                'if_true'   => { name => 'Break' },
                'if_false'  => '1',
                'condition' => {
                    name => 'Str.Eq',
                    args => {
                        arg1           => '6',
                        arg2 => {name => 'Symbol',
                                 args => {symbol => 'what'} },
                    }
                }
            }
        },
        {name => 'remember', args => { what => { name => 'Symbol',
                                                 args => { symbol => 'what'} } } } ],
    signature => {
        'what' => Lorzy::FunctionArgument->new( name => 'what' => type => 'Str') },
);

$eval->set_global_symbol( 'loop-code' => $loop_code );

$eval->apply_script(
    $builder->defun(
    ops => [
        { name => 'ForEach',
            args => {
                list => { name => 'get-list', args => {} },
                binding => 'what',
                do => {name => 'Symbol',
                       args => {symbol => 'loop-code'} },
                    }
        } ],
    signature => { }),
 {});
is_deeply(\@remembered, [1..5]);

@remembered = ();
my $loop_code2 = $builder->defun(
    ops => [
        {   name => 'IfThen',
            args => {
                'if_true'   => { name => 'Continue' },
                'if_false'  => '1',
                'condition' => {
                    name => 'Str.Eq',
                    args => {
                        arg1           => '6',
                        arg2 => {name => 'Symbol',
                                 args => {symbol => 'what'} },
                    }
                }
            }
        },
        {name => 'remember', args => { what => { name => 'Symbol',
                                                 args => { symbol => 'what'} } } } ],
    signature => {
        'what' => Lorzy::FunctionArgument->new( name => 'what' => type => 'Str') },
);


$eval->set_global_symbol( 'loop-code' => $loop_code2 );

$eval->apply_script(
    $builder->defun(
    ops => [
        { name => 'ForEach',
            args => {
                list => { name => 'get-list', args => {} },
                binding => 'what',
                do => {name => 'Symbol',
                       args => {symbol => 'loop-code'} },
                    }
        } ],
    signature => { }),
 {});
is_deeply(\@remembered, [1..5,7..10]);
