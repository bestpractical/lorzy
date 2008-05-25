
package PIE::Expression;
use PIE::FunctionArgument;
use Moose;

with 'PIE::Evaluatable';    

has name => (
   is => 'ro',
   isa => 'Str');

has elements => (
   is => 'ro',
   isa => 'ArrayRef');

has signature => ( 
    is => 'rw',
    default => sub { {}},
    isa => 'HashRef[PIE::FunctionArgument]');

has args => (
    is => 'rw',
    default => sub { {} },
    isa => 'HashRef[PIE::Expression]');

#Attribute (args) does not pass the type constraint because: Validation failed for 'HashRef[PIE::FunctionArgument]' failed with value HASH(0x9a979c) at /opt/local/lib/perl5/site_perl/5.8.8/Moose/Meta/Attribute.pm line 340

# (foo bar (orz 1 ))
# === (eval 'foo bar (orz 1))
# === (apply foo ((bar (orz 1))



sub evaluate {
    my ($self, $ev) = @_;
    my $lambda = $ev->resolve_symbol_name($self->name);
    $ev->apply_script( $lambda, $self->args );
    return $ev->result->value;
}


package PIE::Expression::True;
use Moose;

extends 'PIE::Expression';
sub evaluate {1}

package PIE::Expression::False;
use Moose;
extends 'PIE::Expression::True';

sub evaluate {
    my $self = shift;
    return ! $self->SUPER::evaluate();

}
package PIE::Expression::IfThen;
use Moose;
extends 'PIE::Expression';
use Params::Validate qw/validate_pos/;

has signature => (
    is      => 'ro',
    default => sub {
         {
            condition => PIE::FunctionArgument->new(
                name => 'condition',
                type  => 'PIE::Evaluatable'),

            if_true => PIE::FunctionArgument->new(
                name => 'if_true',
                type  => 'PIE::Evaluatable'),
           if_false => PIE::FunctionArgument->new(
                name => 'if_false',
                type  => 'PIE::Evaluatable'
                )
            }
    }
);

sub evaluate {
    my ($self, $evaluator) = validate_pos(@_, { isa => 'PIE::Expression'}, { isa => 'PIE::Evaluator'}, );

    my $truth= $self->args->{condition}->evaluate($evaluator);
    if ($truth) {
        return    $self->args->{if_true}->evaluate($evaluator);
        }    else { 
        return $self->args->{if_false}->evaluate($evaluator);
    }
}

package PIE::Expression::String;
use Moose;
extends 'PIE::Expression';
use Params::Validate qw/validate_pos/;

has signature => (
    is      => 'ro',
    default => sub {
        { value => PIE::FunctionArgument->new( name => 'value', type => 'Str' )
        };
    }
);

has args => (
    is => 'rw',
    default => sub { {} },
    isa => 'HashRef[Str]');


sub evaluate {
    my ( $self, $eval ) = validate_pos(
        @_,
        { isa => 'PIE::Expression' },
        { isa => 'PIE::Evaluator' }
    );


    return $self->args->{'value'};

}

package PIE::Expression::ProgN;
use Moose;
extends 'PIE::Expression';

has nodes => (
    is => 'rw',
    isa => 'ArrayRef',
);

sub evaluate {
    my ($self, $evaluator) = @_;
    my $res;
    Carp::cluck unless $self->nodes;
    foreach my $node (@{$self->nodes}) {
       $res =  $node->evaluate($evaluator);
    }
    return $res;
}

package PIE::Expression::Symbol;
use Moose;
extends 'PIE::Expression';
use Params::Validate qw/validate_pos/;

has signature => (
    is => 'ro',
    default => sub { { symbol => PIE::FunctionArgument->new( name => 'symbol', type => 'Str')}});
    
    
sub evaluate {
    my ($self, $eval) = validate_pos(@_, { isa => 'PIE::Expression'}, { isa => 'PIE::Evaluator'});
    my $symbol = $self->{'args'}->{'symbol'}->evaluate($eval);
    my $result = $eval->resolve_symbol_name($symbol);
    return $result->meta->does_role('PIE::Evaluatable') ? $result->evaluate($eval): $result; # XXX: figure out evaluation order here
}

1;

