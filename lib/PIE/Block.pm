package PIE::Block;
use Moose::Role;

our $BLOCK_IDS = 0;

has block_id => (
                 is => 'ro',
                 isa => 'Num',
                 default => sub { ++$BLOCK_IDS },
);

has outter_block => (
                     is => 'rw',
                     weak_ref => 1,
                     default => sub { undef },
);

around 'new' => sub {
    my $next = shift;
    my $class = shift;
    my $self = $class->$next(@_);
    return $self if ref($self) eq 'PIE::Lambda::Native';
    $self->_walk( $self,
                  sub { my $block = shift;
                        return unless $block->does('PIE::Block');
                        $block->outter_block($self);
                        return 1;
                    } );

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


1;
