package PIE::Block;
use Moose::Role;

our $BLOCK_IDS = 0;

has block_id => (
                 is => 'ro',
                 isa => 'Num',
                 default => sub { ++$BLOCK_IDS },
);

has outter_scope => (
                     is => 'ro',
                     isa => 'Num',
                     default => sub { 0 },
);
