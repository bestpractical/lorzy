
package PIE::Lambda::Native;
use Moose; 
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);

sub bind_expressions {
    my ($self, $ev, @exp) = @_;
    return;
}

sub evaluate {
    my $self = shift;
    my $ev = shift;
    my $bindings = $self->bindings;
    Carp::croak "unmatched number of arguments" unless $#{$bindings} == $#_;

    $self->body->(map {$ev->run($_); $ev->result->value } @_);
}

1;
