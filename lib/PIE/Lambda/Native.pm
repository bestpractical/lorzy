
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

sub evaluate {
    my $self = shift;
    my $evaluator = shift;
    $self->check_bindings(\@_);
    $self->body->(map {$evaluator->run($_); $evaluator->result->value } @_);
}

1;
