
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
    
has named => (
             metaclass => 'Collection::Hash',
             is        => 'rw',
             default   => sub { {} },
             isa => 'HashRef',
             provides  => {
                 get       => 'get_named',
                 set       => 'set_named',
             });

has stack_depth => ( 
            is => 'rw',
            isa => 'Int',
            default => sub { 0}
            );


sub enter_stack_frame {
    my $self = shift;
    $self->stack_depth($self->stack_depth+1);
}

sub leave_stack_frame {
    my $self = shift;
    die "Trying to leave stack frame 0. Too many returns. Something relaly bad happened" if ($self->stack_depth == 0);
    $self->stack_depth($self->stack_depth-1);
}



sub run {
    my $self       = shift;
    my $expression = shift;
    $self->enter_stack_frame;
    eval {
        Carp::confess unless ($expression);
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

    $self->trace();
    
    $self->leave_stack_frame;
    return 1;

}

sub trace{}


sub resolve_name {
    my ($self, $name) = @_;
    $self->get_named($name);
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
    #$lambda->args( $args );

   my $ret = $lambda->evaluate( $self => $args);
   warn "Coming back from te script, our ret was $ret";
        $self->result->value($ret);
        $self->result->success(1);
}

1;
