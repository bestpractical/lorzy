
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


sub check_args {
    my $self = shift;
    my $passed = shift;
    my $bindings = $self->bindings;
    Carp::croak "unmatched number of arguments. ".($#{$bindings}+1)." expected. Got ".($#{$passed}+1) unless $#{$bindings} == $#{$passed};

}

sub bind_expressions {
    my ($self, $ev, @exp) = @_;
    $self->check_args(\@exp);
    my $bindings = $self->bindings;
    $ev->set_named( $bindings->[$_] => $exp[$_] ) for 0.. $#exp;
}

sub evaluate {
    my $self = shift;
    my $evaluator = shift;

    $self->bind_expressions( $evaluator, @_ );

    foreach my $node (@{$self->nodes}) {
        $evaluator->run($node);
    }
}


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
    
    die if (keys %$missing || keys %$unwanted);
    
    my $arguments = $self->args;
    for (sort keys %$arguments) {
        $evaluator->set_named( $_ => $arguments->{$_} );
    }
    foreach my $node (@{$self->nodes}) {
        $evaluator->run($node);
    }
    
    
}

1;
