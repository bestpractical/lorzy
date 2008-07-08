package Lorzy::Expression::True;
use Moose;
use MooseX::ClassAttribute;

extends 'Lorzy::Expression';

class_has signature => (
    is      => 'ro',
    default => sub { {} } ,
);

sub evaluate { 1 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

