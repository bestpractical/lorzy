
package PIE::Lambda;
use Moose; use MooseX::Params::Validate;
with 'PIE::Evaluatable';

has nodes => (
    is => 'rw',
    isa => 'ArrayRef',
);

has bindings => (
    is => 'rw',
    isa => 'ArrayRef[Str]');

has args => (
    is => 'rw',
    isa => 'HashRef[PIE::FunctionArgument]');


sub check_named_args {
    my $self = shift;
    my $passed = shift; #reference to hash of provided args
    my $args = $self->args; # expected args
    
    
    my $missing = {};
    my $unwanted = {};
    
    my $fail =0;
    foreach my $arg (keys %$passed) {
            if  (!$args->{$arg}) {
            $unwanted->{$arg} =  "The caller passed $arg which we were not expecting" ;
            $fail++
            };
    }
    foreach my $arg (keys %$args) {
                 if  (!$passed->{$arg}) {

                $missing->{$arg} =  "The caller did not pass $arg which we require";
                }
    }

    return $missing, $unwanted;
}



sub evaluate_named_args {
    my ($self, $evaluator, $args) = @_;
    
    my ($missing, $unwanted)  = $self->check_named_args($args);
    
    return undef if (keys %$missing || keys %$unwanted);
    
    my $arguments = $self->args;
    for (sort keys %$arguments) {
        $evaluator->set_named( $_ => $arguments->{$_} );
    }
    foreach my $node (@{$self->nodes}) {
        $evaluator->run($node);
    }
    
    
}

1;
