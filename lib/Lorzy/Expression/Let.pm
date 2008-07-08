package Lorzy::Expression::Let;
use Moose;
extends 'Lorzy::Expression::ProgN';
with 'Lorzy::Block';

has bindings => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { { } },
);

has lambda => (
    is      => 'ro',
    isa     => 'Lorzy::Lambda',
    lazy    => 1,
    default => sub {
        my $self = shift;
        Lorzy::Lambda->new(
            progn       => Lorzy::Expression::ProgN->new(nodes => $self->nodes),
            signature   => $self->mk_signature,
            block_id    => $self->block_id,
            outer_block => $self->outer_block,
        );
    },
);

sub BUILD {
    my ($self, $params) = @_;

    return unless $params->{builder};
    my $bindings = $params->{builder_args}{bindings};

    $self->bindings->{$_} = $params->{builder}->build_expression($bindings->{$_})
        for keys %$bindings;
}

sub mk_signature {
    my $self = shift;
    return {
        map { $_ => Lorzy::FunctionArgument->new( name => $_, type => 'Str') }
            keys %{ $self->bindings }
    };
}

sub evaluate {
    my ($self, $evaluator) = @_;
    $self->lambda->apply($evaluator, $self->bindings);
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

