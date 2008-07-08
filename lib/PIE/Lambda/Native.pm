
package PIE::Lambda::Native;
use Moose; 
use YAML;
use Scalar::Defer;
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);



sub apply {
    my ( $self, $evaluator, $args ) = @_;

    $self->validate_args_or_die($args);
    my $r = $self->body->( {map { $_ => $args->{$_}->evaluate($evaluator) } keys %$args });
    return $r;
}


1;
