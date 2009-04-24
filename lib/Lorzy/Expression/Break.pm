package Lorzy::Expression::Break;
use Moose;
use MooseX::ClassAttribute;

extends 'Lorzy::Expression';

class_has signature => (
    is      => 'ro',
    default => sub { {} } ,
);

sub evaluate {
    my ($self, $evaluator) = @_;
    $evaluator->throw_exception( 'Lorzy::Exception::Loop' => '',
                                 instruction => 'break');
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

