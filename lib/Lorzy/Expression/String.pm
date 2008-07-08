package Lorzy::Expression::String;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

use Params::Validate qw/validate_pos/;

class_has signature => (
    is      => 'ro',
    default => sub {
        return {
            value => Lorzy::FunctionArgument->new(
                name => 'value',
                type => 'Str',
            ),
        };
    }
);

has '+args' => (
    isa => 'HashRef[Str]',
);

sub evaluate {
    my ($self, $eval) = validate_pos(
        @_,
        { isa => 'Lorzy::Expression' },
        { isa => 'Lorzy::Evaluator'  },
    );

    return $self->args->{'value'};
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

