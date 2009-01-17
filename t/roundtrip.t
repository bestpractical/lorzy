#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 7;
use Test::Exception;
use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::Lambda::Native');

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();

$eval->load_package('Native');

my $script = $builder->defun(
                             ops => [
                                     { name => 'ProgN',
                                       args => {
                                                nodes => [
                                                          { name => 'Native.Invoke', args => 
                                                            { obj => { name => 'Symbol', args => { symbol => 'something' } },
                                                              method => 'hello',
                                                              args => { name => 'List', nodes => [ 'orz' ] },
                                                                                     } },
                         ],
                                               } } ],
                            signature => { something => 
                                               Lorzy::FunctionArgument->new( name => 'tested-string')});

isa_ok($script, "Lorzy::Lambda");
my $ret;
lives_ok {
    $ret = $eval->apply_script( $script, { 'something' => bless {}, 'TestClass' } );
};
is($ret, 'world');

package TestClass;

sub hello {
    return 'world';
}
