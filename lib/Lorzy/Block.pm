package Lorzy::Block;
use Moose::Role;

our $BLOCK_IDS = 0;

has block_id => (
    is      => 'ro',
    isa     => 'Num',
    default => sub { ++$BLOCK_IDS },
);

has outer_block => (
    is       => 'rw',
    weak_ref => 1,
);

sub BUILD {
    my $self = shift;
    return $self if ref($self) eq 'Lorzy::Lambda::Native';
    $self->_walk(
        $self,
        sub {
            my $block = shift;
            return unless $block->does('Lorzy::Block');
            $block->outer_block($self);
            return 1;
        },
    );

    return $self;
};

sub _walk {
    my ($self, $exp, $cb) = @_;

    if ($exp->can('nodes')) {
        for (@{$exp->nodes}) {
            next unless ref($_);
            $cb->($_) and next;
            $self->_walk($_, $cb);
        }
    }
    else {
        for (keys %{$exp->signature}) {
            next unless ref($exp->args->{$_});
            $cb->($exp->args->{$_}) and next;
            $self->_walk($exp->args->{$_}, $cb);
        }
    }
}

no Moose::Role;

1;

