package Lorzy::Package;
use Moose;
use MooseX::ClassAttribute;

class_has functions => (
    is      => 'rw',
    isa     => 'HashRef',
    default => sub { {} },
);

sub defun {
    my ($pkg, $name, %args) = @_;
    $pkg->functions->{$name} = \%args;
}

1;
