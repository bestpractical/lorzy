package Lorzy::Expression::Symbol;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

use Params::Validate qw/validate_pos/;

class_has signature => (
    is => 'ro',
    default => sub {
        return {
            symbol => Lorzy::FunctionArgument->new(
                name => 'symbol',
                type => 'Str',
            ),
        };
    },
);

sub evaluate {
    my ($self, $eval) = validate_pos(@_,
        { isa => 'Lorzy::Expression' },
        { isa => 'Lorzy::Evaluator'  },
    );

    my $symbol = $self->{'args'}->{'symbol'}->evaluate($eval);
    my $result = $eval->resolve_symbol_name($symbol);

    return $eval->evaluated_result($result);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

