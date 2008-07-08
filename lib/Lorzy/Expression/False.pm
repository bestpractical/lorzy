package Lorzy::Expression::False;
use Moose;
extends 'Lorzy::Expression::True';

sub evaluate { 0 }

__PACKAGE__->meta->make_immutable;
no Moose;

1;

