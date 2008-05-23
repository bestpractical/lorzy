
package PIE::Expression;
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
    my $lambda = $ev->resolve_name($self->name);
    die "Function ".$self->name." not defined"  unless $lambda;
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

package PIE::Expression::Loop;
use Moose;
extends 'PIE::Expression';

has signature => (
    is => 'ro',
    default => sub {  items => PIE::FunctionArgument->new(name => 'items', type => 'ArrayRef[PIE::Evaluatable]'),
                      block => PIE::FunctionARgument->new(name => 'block', type => 'PIE::Evaluatable')}

);


sub evaluate {
    my $self = shift;

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
                isa  => 'PIE::Evaluatable'),

            if_true => PIE::FunctionArgument->new(
                name => 'if_true',
                isa  => 'PIE::Evaluatable'),
           if_false => PIE::FunctionArgument->new(
                name => 'if_false',
                isa  => 'PIE::Evaluatable'
                )
            }
    }
);

sub evaluate {
    my ($self, $evaluator) = validate_pos(@_, { isa => 'PIE::Expression'}, { isa => 'PIE::Evaluator'}, );
    $evaluator->run($self->args->{condition});
    if ($evaluator->result->value) {
        $evaluator->run($self->args->{if_true});
        return $evaluator->result->value;
        }    else { 
        $evaluator->run($self->args->{if_false});
        return $evaluator->result->value;
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

package PIE::Expression::Symbol;
use Moose;
extends 'PIE::Expression';
use Params::Validate qw/validate_pos/;

has signature => (
    is => 'ro',
    default => sub { { symbol => PIE::FunctionArgument->new( name => 'symbol', type => 'Str')}});
    
    
sub evaluate {
    my ($self, $eval) = validate_pos(@_, { isa => 'PIE::Expression'}, { isa => 'PIE::Evaluator'});
    my $result = $eval->resolve_name($self->args->{'symbol'});
    return $result->isa('PIE::Expression') ? $eval->run($result) : $result; # XXX: figure out evaluation order here
}

1;

