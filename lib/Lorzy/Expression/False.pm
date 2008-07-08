package Lorzy::Expression::False;
use Moose;
extends 'Lorzy::Expression::True';

sub evaluate { 0 }

1;

