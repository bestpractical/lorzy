
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

has lex_block_map => (
                     is => 'rw',
                     isa => 'HashRef[ArrayRef[Num]]',
                     default => sub { {} },
);

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

has stack_block => (
    is => 'rw',
    metaclass => 'Collection::Array',
    isa       => 'ArrayRef[PIE::Block]',
    default   => sub { [] },
    provides  => {
        'push' => 'push_stack_block',
        'pop'  => 'pop_stack_block',
    }
);

has stack_depth => ( 
            is => 'rw',
            isa => 'Int',
            default => sub { 0}
            );


sub enter_stack_frame {
    my $self = shift;
    my %args = validate(@_, {args => 1, block => 1});

    $self->stack_depth($self->stack_depth+1);
    $self->push_stack_vars($args{'args'});
    $self->push_stack_block($args{'block'});

    push @{ $self->lex_block_map->{ $args{'block'}->block_id } ||= [] }, $#{ $self->stack_vars };
}

sub leave_stack_frame {
    my $self = shift;
    die "Trying to leave stack frame 0. Too many returns. Something relaly bad happened" if ($self->stack_depth == 0);
    $self->pop_stack_vars();
    my $block = $self->pop_stack_block();
    $self->stack_depth($self->stack_depth-1);

    pop @{ $self->lex_block_map->{ $block->block_id } };
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

sub lookup_lex_name {
    my ($self, $name) = @_;

    return unless @{ $self->stack_block };

    my $block = $self->stack_block->[-1];
    do {
        my $stack = $self->stack_vars->[ $self->lex_block_map->{ $block->block_id }[-1] ];
        return $stack->{$name} if exists $stack->{$name};
    } while ($block = $block->outter_block);

    return;
}

sub resolve_symbol_name {
    my ($self, $name) = @_;
    my $stack = $self->stack_vars->[-1] || {};
    Carp::cluck if ref($name);
    $stack->{$name} || $self->lookup_lex_name($name) || $self->get_global_symbol($name)
        || die "Could not find symbol $name in the current lexical context.";
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
#    Carp::cluck Dumper($lambda); use Data::Dumper;
    my $ret = $lambda->apply( $self => $args );
    $self->result->value($ret);
    $self->result->success(1);
    return $self->result->value;
}

sub core_expression_signatures {
    my $self = shift;
    my %signatures;
    foreach my $core_expression ( $self->_enumerate_core_expressions() ) {
        my $sig = $self->_flatten_core_expression_signature($core_expression);
        $signatures{$core_expression} =  $sig;
    }

    return \%signatures;
}

sub _enumerate_core_expressions {
    my $self = shift;
    no strict 'refs';
    use PIE::Expression;
    my @core_expressions
        = grep { $_ && $_->isa('PIE::Expression') }
        map { /^(.*)::$/ ? 'PIE::Expression::' . $1 : '' }
        keys %{'PIE::Expression::'};
    return @core_expressions;
}


sub _flatten_core_expression_signature {
    my $self    = shift;
    my $core_expression = shift;
    my $signature = $core_expression->signature;
    return { map { $_->name =>  {type => $_->type}}   values %$signature};

}

sub symbol_signatures {
    my $self = shift;
    my %signatures;
    foreach my $symbol ($self->_enumerate_symbols()) {
        $signatures{$symbol} = $self->_flatten_symbol_signature( $symbol)
    }
    return \%signatures;
}

sub _enumerate_symbols() {
    my $self = shift;
    return keys %{$self->global_symbols};
}


sub _flatten_symbol_signature {
    my $self = shift;
    my $sym = shift;

    my $x = $self->resolve_symbol_name($sym);
    my $signature = $x->signature;
    return { map { $_->name =>  {type => $_->type}}   values %$signature};
    


}

1;
