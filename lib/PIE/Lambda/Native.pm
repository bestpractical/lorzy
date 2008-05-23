
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
    my ( $self, $evaluator ) = @_;

    $self->validate_args_or_die;

    my %args;
    foreach my $key ( keys %{ $self->args } )  {
        $args{$key} = lazy {  
                        $evaluator->run( $self->args->{$key} );
                        $evaluator->result->value  
                    } 
    } 
    my $r = $self->body->( \%args );
    return $r;
}


1;
