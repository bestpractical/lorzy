package Lorzy::Expression::ForEach;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

class_has signature => (
    is      => 'ro',
    default => sub {
        return {
            list => Lorzy::FunctionArgument->new(
                name => 'list',
            ),
            binding => Lorzy::FunctionArgument->new(
                name => 'Str',
            ),
            do => Lorzy::FunctionArgument->new(
                name => 'Str',
                type => 'Lorzy::Lambda', # XXX: type for runtime?
            ),
        };
    },
);

sub evaluate {
    my ($self, $evaluator) = @_;

    my $lambda  = $self->args->{do}->evaluate($evaluator);
    my $binding = $self->args->{binding}->evaluate($evaluator);
    my $list    = $self->args->{list}->evaluate($evaluator);

    die "Invalid do-block $lambda" unless $lambda->isa("Lorzy::Lambda");
    die "Invalid 'list' $list" unless ref($list) eq 'Lorzy::EvaluatorResult::RunTime';

    my $nodes = $$list;

    foreach (@$nodes) {
        $lambda->apply($evaluator, { $binding => $_ });
    }
}

1;

