
package PIE::Lambda::Native;
use Moose; 
use YAML;
use Scalar::Defer;
extends 'PIE::Lambda';

has body => (
    is => 'ro',
#    isa => 'CODE',
);



sub evaluate {
    my ( $self, $evaluator, $args ) = @_;

    $self->validate_args_or_die($args);

    my %args;
    foreach my $key ( keys %$args ) {
        $evaluator->run( $args->{$key} );
        $args{$key} = $evaluator->result->value;

    }
    my $r = $self->body->( \%args );
    return $r;
}


1;
