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
    my %args = map { $_ => $args->{$_}->evaluate($evaluator) } keys %$args;
    my $r = $self->body->(\%args);
    return $r;
}

1;

