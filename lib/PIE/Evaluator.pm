
package PIE::Evaluator;
use Moose;
use MooseX::AttributeHelpers;
use PIE::EvaluatorResult;
use Params::Validate;

has result => ( 
    is => 'ro',
    isa => 'PIE::EvaluatorResult',
    default => sub { return PIE::EvaluatorResult->new()}
    );
    
has global_symbols => (
             metaclass => 'Collection::Hash',
             is        => 'rw',
             default   => sub { {} },
             isa => 'HashRef',
             provides  => {
                 get       => 'get_global_symbol',
                 set       => 'set_global_symbol',
             });

has stack_vars => (
    is => 'rw',
    metaclass => 'Collection::Array',
    isa       => 'ArrayRef[HashRef]',
    default   => sub { [] },
    provides  => {
        'push' => 'push_stack_vars',
        'pop'  => 'pop_stack_vars',
    }
);

has stack_depth => ( 
            is => 'rw',
            isa => 'Int',
            default => sub { 0}
            );


sub enter_stack_frame {
    my $self = shift;
    my %args = validate(@_, {args => 1});

    $self->stack_depth($self->stack_depth+1);
    $self->push_stack_vars($args{'args'});
}

sub leave_stack_frame {
    my $self = shift;
    die "Trying to leave stack frame 0. Too many returns. Something relaly bad happened" if ($self->stack_depth == 0);
    $self->pop_stack_vars();
    $self->stack_depth($self->stack_depth-1);
}

sub run {
    my $self       = shift;
    my $expression = shift;
    eval {
        Carp::confess unless ($expression && $expression->can('evaluate'));
        my $ret = $expression->evaluate($self);


        $self->result->value($ret);
        $self->result->success(1);
    };
    if ( my $err = $@ ) {
        #        die $err; # for now

        $self->result->success(0);
        $self->result->value(undef);
        $self->result->error($err);
    }
    return $self->result->success;
}

sub resolve_symbol_name {
    my ($self, $name) = @_;
    my $stack = $self->stack_vars->[-1] || {};
    Carp::cluck if ref($name);
    $stack->{$name} || $self->get_global_symbol($name) || die "Could not find symbol $name in the current lexical context.";
}

sub apply_script {

# self, a lambda, any number of positional params. (to be replaced with a params object?)
    my ( $self, $lambda, $args ) = validate_pos(
        @_,
        { isa => 'PIE::Evaluator' },
        { ISA => 'PIE::Lambda' },
        { ISA => "HASHREF" }
    );
    Carp::confess unless($lambda);
    my $ret = $lambda->apply( $self => $args);
    $self->result->value($ret);
    $self->result->success(1);
    return $self->result->value;
}

1;
