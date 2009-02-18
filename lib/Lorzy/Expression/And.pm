package Lorzy::Expression::And;
use Moose;
extends 'Lorzy::Expression::ProgN';

sub evaluate {
    my ($self, $evaluator) = @_;
    for (@{$self->nodes}) {
        $evaluator->evaluated_result($_) or return 0;
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

