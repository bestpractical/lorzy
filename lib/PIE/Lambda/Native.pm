
package PIE::Lambda::Native;
use Moose; 
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);

sub bind_expressions {
    my ($self, $evaluator, @exp) = @_;
    return;
}

sub evaluate {
    my $self = shift;
    my $evaluator = shift;
    $self->check_bindings(\@_);
    $self->body->(map {$evaluator->run($_); $evaluator->result->value } @_);
}




sub evaluate_named_args {
    my ($self, $evaluator, $args) = @_;

    
    my ($missing, $unwanted)  = $self->check_named_args($args);
    

    die "Something went wrong with your args" if (keys %$missing || keys %$unwanted);
    
    my $arguments = $self->args;
    my %args = map { $evaluator->run($args->{$_}); ( $_ => $evaluator->result->value ) } keys %$args;
    # XXX TODO - these are eagerly evaluated at this point. we probably want to lazy {} them with Scalar::Defer
    my $r = $self->body->(%args);    
    return $r;
}


1;
