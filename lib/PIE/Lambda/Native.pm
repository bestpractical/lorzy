
package PIE::Lambda::Native;
use Moose; 
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);

sub bind_expressions {
    my ($self, $ev, @exp) = @_;
    my $bindings = $self->bindings;
    Carp::croak "unmatched number of arguments" unless $#{$bindings} == $#exp;

    return;
    Carp::croak "unmatched number of arguments" unless $#{$bindings} == $#exp;
    $ev->set_named( $bindings->[$_] => $exp[$_] ) for 0.. $#exp;
}

sub evaluate {
    my $self = shift;
    my $ev = shift;
    $self->body->(map {$ev->run($_); $self->result->value } @_);
}

1;
