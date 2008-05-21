
package PIE::Evaluator;
use Moose;
use MooseX::AttributeHelpers;
use PIE::EvaluatorResult;


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
    my $self = shift;
    my $expression = shift;
    eval { 
    my $ret = $expression->evaluate($self);
    $self->result->value($ret) ; # XXX TODO - we should be separating out success and value
    $self->result->success(1);
    };
    if (my $err = $@) {
        die $err; # for now
    
        $self->result->success(0);
        $self->result->error($err);
    }

    return 1;
}

sub resolve_name {
    my ($self, $name) = @_;
    $self->get_named($name);
}


sub apply_script {
    my ($self, $lambda, @exp) = @_;
    if (ref($lambda) eq 'CODE') {
        warn " deprecated";
        $lambda->(map {$self->run($_); $self->result->value } @exp);    
    }
    elsif ($lambda->isa("PIE::Lambda")) {
        # XXX: cleanup, unmask, etc
        $lambda->evaluate($self, @exp);
    }
    else {
        die 'wtf';
    }
}


1;
