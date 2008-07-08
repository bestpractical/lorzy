#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 15;

use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::FunctionArgument');
use_ok('Lorzy::Lambda::Native');

package Hello;

use Moose;
use MooseX::AttributeHelpers;

has 'evaluator' => (
    is      => 'rw',
    isa     => 'Lorzy::Evaluator',
    lazy    => 1,
    default => sub { return Lorzy::Evaluator->new() },
);

has 'rules' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
);

sub run {
    my $self = shift;
    my $name = shift;

     my $args = { name => Lorzy::Expression::String->new( args => { value => $name } ) };
    for ( @{ $self->rules } ) {
        $self->evaluator->apply_script( $_, $args);

        last unless ( $self->evaluator->result->success );
        $name = $self->evaluator->result->value;
    }

    return "Hello $name";
}

package main;

is( Hello->new->run('jesse'), 'Hello jesse' );

my $hello = Hello->new;
isa_ok( $hello => 'Hello' );

$hello->evaluator->set_global_symbol( 'make-fred',
    Lorzy::Lambda::Native->new( body => sub { return 'fred' } ) );
$hello->evaluator->set_global_symbol( 'make-bob',
    Lorzy::Lambda::Native->new( body => sub { return 'bob' } ) );

$hello->evaluator->set_global_symbol(
    'make-whoever',
    Lorzy::Lambda::Native->new(
        body => sub { my $args = shift; return $args->{'name'} },
        signature => {
            name => Lorzy::FunctionArgument->new( name => 'name', type => 'Str' )
            }

    )
);

my $tree    = [ { name => 'make-fred' } ];
my $builder = Lorzy::Builder->new();
my $script  = $builder->defun(
    ops => $tree,
    signature =>
        { name => Lorzy::FunctionArgument->new( name => 'name', type => 'Str' ) }
);

$hello->rules( [$script] );
isa_ok( $hello->rules->[0], 'Lorzy::Lambda' );
is( $hello->run('jesse'), 'Hello fred' );

my $script2 = $builder->defun(
    ops => [ { name => 'make-bob' }, { name => 'make-fred' } ],
    signature =>
        { name => Lorzy::FunctionArgument->new( name => 'name', type => 'Str' ) }
);
$hello->rules( [$script2] );
isa_ok( $hello->rules->[0], 'Lorzy::Lambda' );

is( $hello->run('jesse'), 'Hello fred' );

my $script3 = $builder->defun(
    ops => [ { name => 'make-bob' } ],
    signature =>
        { name => Lorzy::FunctionArgument->new( name => 'name', type => 'Str' ) }
);
my $script4 = $builder->defun(
    ops => [ { name => 'make-fred' } ],
    signature =>
        { name => Lorzy::FunctionArgument->new( name => 'name', type => 'Str' ) }
);

$hello->rules( [ $script3, $script4 ] );

isa_ok( $hello->rules->[0], 'Lorzy::Lambda' );
isa_ok( $hello->rules->[1], 'Lorzy::Lambda' );
is( $hello->run('jesse'), 'Hello fred' );

$hello->rules( [ $hello->evaluator->get_global_symbol('make-whoever') ] );
isa_ok( $hello->rules->[0], 'Lorzy::Lambda' );
is( $hello->run('jesse'), 'Hello jesse' );

