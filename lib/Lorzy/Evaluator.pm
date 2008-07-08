package Lorzy::Evaluator;
use Moose;
use MooseX::AttributeHelpers;

use Lorzy::EvaluatorResult;
use Lorzy::Expression;
use Params::Validate;

has result => (
    is      => 'ro',
    isa     => 'Lorzy::EvaluatorResult',
    default => sub { return Lorzy::EvaluatorResult->new },
);

has global_symbols => (
    metaclass => 'Collection::Hash',
    is        => 'rw',
    isa       => 'HashRef',
    default   => sub { {} },
    provides  => {
        get  => 'get_global_symbol',
        set  => 'set_global_symbol',
        keys => '_enumerate_symbols',
    },
);

has lex_block_map => (
    is      => 'rw',
    isa     => 'HashRef[ArrayRef[Num]]',
    default => sub { {} },
);

has stack_block => (
    metaclass => 'Collection::Array',
    is        => 'rw',
    isa       => 'ArrayRef[Lorzy::Block]',
    default   => sub { [] },
    provides  => {
        'push'  => 'push_stack_block',
        'pop'   => 'pop_stack_block',
        'count' => 'stack_depth',
        'last'  => 'top_stack_block',
    }
);

sub enter_stack_frame {
    my $self = shift;
    my %args = validate(@_, {args => 1, block => 1});

    $self->push_stack_block($args{'block'});

    # lex_block_map is a mapping from a block id to an array of stack indexes.
    # if we're entereing block 3, we push the current stack frame  onto the lex_block_map entry for block 3
    #   The last entry of the current block is where we can see its lexical context
    push @{ $self->lex_block_map->{ $args{'block'}->block_id } ||= [] }, $args{'args'};
}

sub leave_stack_frame {
    my $self = shift;
    die "Trying to leave stack frame 0. Too many returns. Something relaly bad happened" if $self->stack_depth == 0;
    my $block = $self->pop_stack_block();

    pop @{ $self->lex_block_map->{ $block->block_id } };
}

sub run {
    my $self       = shift;
    my $expression = shift;
    eval {
        confess unless $expression && $expression->can('evaluate');
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

    return unless $self->stack_depth;

    # look at the current block on the stack
    my $block = $self->top_stack_block;

    do {
        # grab the stack frame from the lexical block map pointer for the 'current' block (the one we're inspecting
        my $stack = $self->lex_block_map->{ $block->block_id }[-1] ;
        # if we find the variable, we can return it

        return $stack->{$name} if exists $stack->{$name};
    } while $block = $block->outer_block;

    return;
}

sub resolve_symbol_name {
    my ($self, $name) = @_;
    Carp::cluck("resolve_symbol_name was called with a reference $name.") if ref $name;
    $self->lookup_lex_name($name) || $self->get_global_symbol($name)
        || die "Could not find symbol $name in the current lexical context.";
}

sub apply_script {
    # self, a lambda, any number of positional params. (to be replaced with a params object?)
    my ($self, $lambda, $args) = validate_pos(
        @_,
        { isa => 'Lorzy::Evaluator' },
        { ISA => 'Lorzy::Lambda' },
        { ISA => "HASHREF" }
    );
    confess "Invalid lambda passed to apply_script" unless $lambda;

    my $ret = $lambda->apply($self => $args);
    $self->result->value($ret);
    $self->result->success(1);
    return $self->result->value;
}

sub core_expression_signatures {
    my $self = shift;
    my %signatures;
    foreach my $core_expression ( $self->_enumerate_core_expressions ) {
        my $sig = $self->_flatten_core_expression_signature($core_expression);
        $signatures{$core_expression} =  $sig;
    }

    return \%signatures;
}

sub _enumerate_core_expressions {
    my $self = shift;
    return Lorzy::Expression->expression_types;
}

sub _flatten_core_expression_signature {
    my ($self, $core_expression) = @_;
    my $signature = $core_expression->signature;
    return {
        map { $_->name => { type => $_->type } } values %$signature,
    };
}

sub symbol_signatures {
    my $self = shift;

    return {
        map { $_ => $self->_flatten_symbol_signature($_) } $self->_enumerate_symbols,
    };
}

sub _flatten_symbol_signature {
    my $self = shift;
    my $sym  = shift;

    my $x = $self->resolve_symbol_name($sym);
    my $signature = $x->signature;

    return {
        map { $_->name => { type => $_->type } } values %$signature
    };
}

1;

