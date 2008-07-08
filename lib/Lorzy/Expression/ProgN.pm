package Lorzy::Expression::ProgN;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

class_has signature => (
    is => 'ro',
    default => sub { {} },
);

has nodes => (
    is  => 'rw',
    isa => 'ArrayRef',
);

sub BUILD {
    my ($self, $params) = @_;

    return unless $params->{builder};
    my $nodes = $params->{builder_args}{nodes};

    $self->nodes([ map { $params->{builder}->build_expression($_) } @$nodes ]);
}

sub evaluate {
    my ($self, $evaluator) = @_;
    Carp::cluck("No nodes to evaluate.") unless $self->nodes;

    my $res;
    foreach my $node (@{$self->nodes}) {
       $res = $node->evaluate($evaluator);
    }
    return $res;
}

1;

