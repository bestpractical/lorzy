
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

has arguments => (
    is => 'rw',
    isa => 'HashRef[PIE::Function::Argument]');

sub bind_expressions {
    my ($self, $ev, @exp) = @_;
    my $bindings = $self->bindings;
    Carp::croak "unmatched number of arguments" unless $#{$bindings} == $#exp;
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

1;
