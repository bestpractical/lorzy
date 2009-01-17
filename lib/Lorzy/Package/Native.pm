package Lorzy::Package::Native;
use base 'Lorzy::Package';

__PACKAGE__->defun( 'Invoke',
    signature => {
        'obj' => Lorzy::FunctionArgument->new( name => 'obj'),
        'method' => Lorzy::FunctionArgument->new( name => 'method', type => 'Str' ),
        'args' => Lorzy::FunctionArgument->new( name => 'args' ),
        },
    native => sub {
        my $args = shift;
        my $method = $args->{method};
        die "Invalid 'args' $args->{args}" unless ref($args->{args}) eq 'Lorzy::EvaluatorResult::RunTime';
        my $nodes = ${$args->{args}};

        $args->{obj}->$method( @$nodes );
    },
);

1;
