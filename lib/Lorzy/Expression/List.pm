package Lorzy::Expression::List;
use Moose;
extends 'Lorzy::Expression::ProgN';

sub evaluate {
    my ($self, $evaluator) = @_;
    return bless \$self->nodes, 'Lorzy::EvaluatorResult::RunTime';
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

