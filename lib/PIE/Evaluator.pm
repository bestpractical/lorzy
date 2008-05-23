
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

sub run {
    my $self       = shift;
    my $expression = shift;
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

    return 1;
}

sub resolve_name {
    my ($self, $name) = @_;
    $self->get_named($name);
}


sub apply_script {
    # self, a lambda, any number of positional params. (to be replaced with a params object?)
    my ($self, $lambda, $args) = validate_pos(@_, { isa => 'PIE::Evaluator'}, { ISA => 'PIE::Lambda'}, { ISA => "HASHREF" } ) ;
    $lambda->evaluate($self, $args);
}

1;
