package Lorzy::Lambda::Native;
use Moose;
extends 'Lorzy::Lambda';

has body => (
    is  => 'ro',
    isa => 'CodeRef',
);

sub apply {
    my ($self, $evaluator, $args) = @_;
    $self->validate_args_or_die($args);
    my %args = map { $_ => $evaluator->evaluated_result($args->{$_}) }
        keys %$args;
    my $r = $self->body->(\%args, $evaluator);
    return $r;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

