
package PIE::Lambda;
use Moose; use MooseX::Params::Validate;

has nodes => (
    is => 'rw',
    isa => 'ArrayRef',
);

has signature => (
    is => 'rw',
    isa => 'HashRef[PIE::FunctionArgument]');

sub check_args {
    my $self = shift;
    my $passed = shift; #reference to hash of provided args
    my $expected = $self->signature; # expected args
    
    
    my $missing = {};
    my $unwanted = {};
    
    my $fail =0;
    foreach my $arg (keys %$passed) {
            if  (!$expected->{$arg}) {
            $unwanted->{$arg} =  "The caller passed $arg which we were not expecting" ;
            };
    }
    foreach my $arg (keys %$expected) {
                 if  (!$passed->{$arg}) {

                $missing->{$arg} =  "The caller did not pass $arg which we require";
                }
    }

    return $missing, $unwanted;
}

sub validate_args_or_die {
    my $self = shift;
    my $args = shift;
    my ( $missing, $unwanted ) = $self->check_args( $args);

    if ( keys %$missing || keys %$unwanted ) {
        die "Function signature mismatch \n".
        (keys %$missing? "The following arguments were missing: " . join(", ", keys %$missing) ."\n" : ''),
        (keys %$unwanted? "The following arguments were unwanted: " . join(", ", keys %$unwanted)."\n" : '');

    }
} 

sub apply {
    my ($self, $evaluator, $args) = @_;


    $self->validate_args_or_die($args);

    my $arguments = $self->signature;

    $evaluator->push_stack_vars( $args );
    my $res;
    foreach my $node (@{$self->nodes}) {
       $res =  $node->evaluate($evaluator);
    }

    $evaluator->pop_stack_vars( $args );
    return $res;
    #return $evaluator->result->value; 

    
}

1;
