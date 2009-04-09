package Lorzy::Lambda::Native;
use Moose;
extends 'Lorzy::Lambda';

has body => (
    is  => 'ro',
    isa => 'CodeRef',
);

sub name {
    my $self = shift;
    return 'Native Code #'.$self->block_id;
}

sub apply {
    my ($self, $evaluator, $args) = @_;
    $self->validate_args_or_die($evaluator, $args);

#    $evaluator->enter_stack_frame(args => $args, block => $self);
    my %args = map { $_ => $evaluator->evaluated_result($args->{$_}) }
        keys %$args;
    my $r = eval { $self->body->(\%args, $evaluator) };
    $evaluator->throw_exception( 'Lorzy::Exception::Native' => 'failed native code: '.$@ )
        if $@;
#    $evaluator->leave_stack_frame;
    return $r;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

