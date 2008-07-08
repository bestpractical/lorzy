package Lorzy::Expression::IfThen;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

use Params::Validate qw/validate_pos/;

class_has signature => (
    is      => 'ro',
    default => sub {
        return {
            condition => Lorzy::FunctionArgument->new(
                name => 'condition',
                type => 'Lorzy::Evaluatable',
            ),
            if_true => Lorzy::FunctionArgument->new(
                name => 'if_true',
                type => 'Lorzy::Evaluatable',
            ),
            if_false => Lorzy::FunctionArgument->new(
                name => 'if_false',
                type => 'Lorzy::Evaluatable',
            ),
        };
    }
);

sub evaluate {
    my ($self, $evaluator) = validate_pos(@_,
        { isa => 'Lorzy::Expression' },
        { isa => 'Lorzy::Evaluator'  },
    );

    my $truth = $self->args->{condition}->evaluate($evaluator);
    if ($truth) {
        return $self->args->{if_true}->evaluate($evaluator);
    } else {
        return $self->args->{if_false}->evaluate($evaluator);
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

