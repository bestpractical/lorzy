
package Lorzy::Expression;
use Lorzy::FunctionArgument;
use Moose;

with 'Lorzy::Evaluatable';    

has name => (
   is => 'ro',
   isa => 'Str');

has elements => (
   is => 'ro',
   isa => 'ArrayRef');

has signature => ( 
    is => 'rw',
    default => sub { {}},
    isa => 'HashRef[Lorzy::FunctionArgument]');

has args => (
    is => 'rw',
    default => sub { {} },
    isa => 'HashRef[Lorzy::Expression]');

sub evaluate {
    my ($self, $ev) = @_;
    my $lambda = $ev->resolve_symbol_name($self->name);
    $ev->apply_script( $lambda, $self->args );
    return $ev->result->value;
}

package Lorzy::Expression::True;
use Moose;
use MooseX::ClassAttribute;

extends 'Lorzy::Expression';

class_has signature => ( is => 'ro', default => sub { { }});
sub evaluate {1}

package Lorzy::Expression::False;
use Moose;
extends 'Lorzy::Expression::True';

sub evaluate {
    my $self = shift;
    return ! $self->SUPER::evaluate();

}

package Lorzy::Expression::IfThen;
use Moose;
extends 'Lorzy::Expression';
use Params::Validate qw/validate_pos/;
use MooseX::ClassAttribute;

class_has signature => (
    is      => 'ro',
    default => sub {
         {
            condition => Lorzy::FunctionArgument->new(
                name => 'condition',
                type  => 'Lorzy::Evaluatable'),

            if_true => Lorzy::FunctionArgument->new(
                name => 'if_true',
                type  => 'Lorzy::Evaluatable'),
           if_false => Lorzy::FunctionArgument->new(
                name => 'if_false',
                type  => 'Lorzy::Evaluatable'
                )
            }
    }
);

sub evaluate {
    my ($self, $evaluator) = validate_pos(@_, { isa => 'Lorzy::Expression'}, { isa => 'Lorzy::Evaluator'}, );

    my $truth= $self->args->{condition}->evaluate($evaluator);
    if ($truth) {
        return    $self->args->{if_true}->evaluate($evaluator);
        }    else { 
        return $self->args->{if_false}->evaluate($evaluator);
    }
}

package Lorzy::Expression::String;
use Moose;
extends 'Lorzy::Expression';
use Params::Validate qw/validate_pos/;
use MooseX::ClassAttribute;

class_has signature => (
    is      => 'ro',
    default => sub {
        { value => Lorzy::FunctionArgument->new( name => 'value', type => 'Str' )
        };
    }
);

has '+args' => (
    isa => 'HashRef[Str]');


sub evaluate {
    my ( $self, $eval ) = validate_pos(
        @_,
        { isa => 'Lorzy::Expression' },
        { isa => 'Lorzy::Evaluator' }
    );


    return $self->args->{'value'};

}

package Lorzy::Expression::ProgN;
use MooseX::ClassAttribute;
use Moose;
extends 'Lorzy::Expression';
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

package Lorzy::Expression::Symbol;
use Moose;
extends 'Lorzy::Expression';
use Params::Validate qw/validate_pos/;
use MooseX::ClassAttribute;

class_has signature => (
    is => 'ro',
    default => sub { { symbol => Lorzy::FunctionArgument->new( name => 'symbol', type => 'Str')}});

sub evaluate {
    my ($self, $eval) = validate_pos(@_, { isa => 'Lorzy::Expression'}, { isa => 'Lorzy::Evaluator'});
    my $symbol = $self->{'args'}->{'symbol'}->evaluate($eval);
    my $result = $eval->resolve_symbol_name($symbol);
    return ref($result) && $result->meta->does_role('Lorzy::Evaluatable') ? $result->evaluate($eval): $result; # XXX: figure out evaluation order here
}

package Lorzy::Expression::List;
use Moose;
extends 'Lorzy::Expression::ProgN';

sub evaluate {
    my ($self, $evaluator) = @_;
    return bless \$self->nodes, 'Lorzy::EvaluatorResult::RunTime';
}

package Lorzy::Expression::ForEach;
use Moose;
extends 'Lorzy::Expression';
use MooseX::ClassAttribute;

class_has signature => (
    is => 'ro',
    default => sub { { list => Lorzy::FunctionArgument->new( name => 'list'),
                       binding => Lorzy::FunctionArgument->new( name => 'Str'),
                       do => Lorzy::FunctionArgument->new( name => 'Str', type => 'Lorzy::Lambda'), # XXX: type for runtime?
                   }});

sub evaluate {
    my ($self, $evaluator) = @_;
    my $lambda = $self->args->{do}->evaluate($evaluator);
    die unless $lambda->isa("Lorzy::Lambda");

    my $binding = $self->args->{binding}->evaluate($evaluator);
    my $list = $self->args->{list}->evaluate($evaluator);

    die unless ref($list) eq 'Lorzy::EvaluatorResult::RunTime';
    my $nodes = $$list;

    foreach (@$nodes) {
        $lambda->apply($evaluator, { $binding => $_ });
    }

}

package Lorzy::Expression::Symbol;
use Moose;
extends 'Lorzy::Expression';
use Params::Validate qw/validate_pos/;
use MooseX::ClassAttribute;

class_has signature => (
    is => 'ro',
    default => sub { { symbol => Lorzy::FunctionArgument->new( name => 'symbol', type => 'Str')}});


package Lorzy::Expression::Let;
use Moose;
extends 'Lorzy::Expression::ProgN';
with 'Lorzy::Block';

has bindings => (
    is => 'rw',
    isa => 'HashRef',
    default => sub { { } },
);

has lambda => (
    is => 'ro',
    isa => 'Lorzy::Lambda',
    lazy => 1,
    default => sub {
        my $self = shift;
        Lorzy::Lambda->new(
            progn     => Lorzy::Expression::ProgN->new( nodes => $self->nodes ),
            signature => $self->mk_signature,
            block_id => $self->block_id,
            outer_block => $self->outer_block,
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
    return { map { $_ => Lorzy::FunctionArgument->new( name => $_, type => 'Str') } keys %{ $self->bindings } };
}

sub evaluate {
    my ($self, $evaluator) = @_;
    $self->lambda->apply( $evaluator, $self->bindings );
}

1;
