package Lorzy::Expression::Apply;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

has lambda => (
    is  => 'rw',
    isa => 'Lorzy::Evaluatable',
);

has apply_args => (
    is      => 'rw',
    isa     => 'HashRef[Lorzy::Expression]',
    default => sub { {} },
);

class_has signature => (
    is      => 'ro',
    default => sub {
        return {
            lambda => Lorzy::FunctionArgument->new(
                name => 'lambda',
                type => 'Lorzy::Evaluatable',
            ),
        };
    }
);

sub BUILD {
    my ($self, $params) = @_;
    return unless $params->{builder};
    my $apply_args = $params->{builder_args}{apply_args};
    $self->apply_args->{$_} = $params->{builder}->build_expression($apply_args->{$_})
        for keys %$apply_args;
}

sub evaluate {
    my ($self, $evaluator) = @_;
    my $lambda = $evaluator->evaluated_result($self->args->{lambda});

    return $evaluator->apply_script($lambda, $self->apply_args);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

