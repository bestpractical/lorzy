
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

sub evaluate {
    my ($self, $ev) = @_;
    my $lambda = $ev->resolve_symbol_name($self->name);
    $ev->apply_script( $lambda, $self->args );
    return $ev->result->value;
}

package PIE::Expression::True;
use Moose;
use MooseX::ClassAttribute;

extends 'PIE::Expression';

class_has signature => ( is => 'ro', default => sub { { }});
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
use MooseX::ClassAttribute;

class_has signature => (
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
use MooseX::ClassAttribute;

class_has signature => (
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
use MooseX::ClassAttribute;
use Moose;
extends 'PIE::Expression';
class_has signature => ( is => 'ro', default => sub { { }});

has nodes => (
    is => 'rw',
    isa => 'ArrayRef',
);

sub BUILD {
    my ($self, $params) = @_;

    return unless $params->{builder};
    my $nodes = $params->{builder_args}{nodes};

    $self->nodes( [ map { $params->{builder}->build_expression($_) } @$nodes ] );
}

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
use MooseX::ClassAttribute;

class_has signature => (
    is => 'ro',
    default => sub { { symbol => PIE::FunctionArgument->new( name => 'symbol', type => 'Str')}});

sub evaluate {
    my ($self, $eval) = validate_pos(@_, { isa => 'PIE::Expression'}, { isa => 'PIE::Evaluator'});
    my $symbol = $self->{'args'}->{'symbol'}->evaluate($eval);
    my $result = $eval->resolve_symbol_name($symbol);
    return ref($result) && $result->meta->does_role('PIE::Evaluatable') ? $result->evaluate($eval): $result; # XXX: figure out evaluation order here
}

package PIE::Expression::Let;
use Moose;
extends 'PIE::Expression::ProgN';
with 'PIE::Block';

has bindings => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { { } },
);

has lambda => (
    is => 'ro',
    isa => 'PIE::Lambda',
    lazy => 1,
    default => sub {
        my $self = shift;
        PIE::Lambda->new(
            progn     => PIE::Expression::ProgN->new( nodes => $self->nodes ),
            signature => $self->mk_signature,
            block_id => $self->block_id,
            outter_block => $self->outter_block,
        );
    },
);

sub BUILD {
    my ($self, $params) = @_;

    return unless $params->{builder};
    my $bindings = $params->{builder_args}{bindings};

    $self->bindings->{$_} = $params->{builder}->build_expression($bindings->{$_})
        for keys %$bindings;

}

sub mk_signature {
    my $self = shift;
    return { map { $_ => PIE::FunctionArgument->new( name => $_, type => 'Str') } keys %{ $self->bindings } };
}

sub evaluate {
    my ($self, $evaluator) = @_;
    $self->lambda->apply( $evaluator, $self->bindings );
}

1;
