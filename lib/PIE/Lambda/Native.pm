
package PIE::Lambda::Native;
use Moose; 
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);

sub bind_expressions {
    my ($self, $evaluator, @exp) = @_;
    return;
}

sub evaluatoraluate {
    my $self = shift;
    my $evaluator = shift;
    my $bindings = $self->bindings;
    Carp::croak "unmatched number of arguments" unless $#{$bindings} == $#_;

    $self->body->(map {$evaluator->run($_); $ev->result->value } @_);
}

1;
