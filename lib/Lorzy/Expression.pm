package Lorzy::Expression;
use Moose;
use Lorzy::FunctionArgument;
with 'Lorzy::Evaluatable';

use Module::Pluggable
    require     => 1,
    sub_name    => 'expression_types',
    search_path => __PACKAGE__;

has name => (
   is  => 'ro',
   isa => 'Str',
);

has elements => (
   is      => 'ro',
   isa     => 'ArrayRef',
   default => sub { [] },
);

has signature => (
    is      => 'rw',
    isa     => 'HashRef[Lorzy::FunctionArgument]',
    default => sub { {} },
);

has args => (
    is      => 'rw',
    isa     => 'HashRef[Lorzy::Expression]',
    default => sub { {} },
);

sub evaluate {
    my ($self, $ev) = @_;
    my $lambda = $ev->resolve_symbol_name($self->name);
    $ev->apply_script($lambda, $self->args);
    return $ev->result->value;
}

# force loading of each expression subclass
__PACKAGE__->expression_types;

1;

