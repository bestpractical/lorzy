package Lorzy::Package::Native;
use base 'Lorzy::Package';
use strict;

__PACKAGE__->defun( 'Invoke',
    signature => {
        'obj' => Lorzy::FunctionArgument->new( name => 'obj'),
        'method' => Lorzy::FunctionArgument->new( name => 'method', type => 'Str' ),
        'args' => Lorzy::FunctionArgument->new( name => 'args' ),
        },
    native => sub {
        my $args = shift;
        my $eval = shift;
        my $method = $args->{method};
        die "Invalid 'args' $args->{args}" unless ref($args->{args}) eq 'Lorzy::EvaluatorResult::RunTime';
        my $nodes = ${$args->{args}};

        $args->{obj}->$method( map { $eval->evaluated_result($_) } @$nodes );
    },
);

__PACKAGE__->defun( 'Apply',
    signature => {
        'code' => Lorzy::FunctionArgument->new( name => 'code'),
        'args' => Lorzy::FunctionArgument->new( name => 'args' ),
        },
    native => sub {
        my $args = shift;
        my $eval = shift;
        die "Invalid 'args' $args->{args}" unless ref($args->{args}) eq 'Lorzy::EvaluatorResult::RunTime';
        my $nodes = ${$args->{args}};

        $args->{code}->( map { $eval->evaluated_result($_) }@$nodes );
    },
);

1;
