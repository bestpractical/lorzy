
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



sub evaluate {
    my $self = shift;
    my $evaluator = shift;
#    my %args = validate(@_, { context => 1});
    foreach my $node (@{$self->nodes}) {
        $evaluator->run($node);
        
    }
    
}

1;
