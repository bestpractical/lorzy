
package PIE::Builder;
use Moose;

use PIE::Lambda;
use PIE::Expression;
use UNIVERSAL::require;

sub build_op_expression {
    my ($self, $name, $args) = @_;
    my $class = "PIE::Expression::$name";
    if ($class->require) {
        die unless $class->meta->does_role("PIE::Evaluatable");
        $class->new( map { $_ => $self->build_expression( $args->{$_} ) } keys %$args );
    }
    else {
        PIE::Expression->new( name => $name, args => $args );
    }
}

sub build_expression {
    my ($self, $tree) = @_;
    if (!ref($tree)) {
        return PIE::Expression::String->new(value => $tree );
    }
    elsif (ref($tree) eq 'ARRAY') {
        my ($func, @rest) = @$tree;
        return PIE::Expression->new( elements => [$func, map { $self->build_expression($_) } @rest]);
    }
    elsif (ref($tree) eq 'HASH') {
        return $self->build_op_expression($tree->{name}, $tree->{args});
    }
}


sub build_expressions {
    my $self = shift;
    my $ops = shift;

    return PIE::Lambda->new( nodes => [map { $self->build_expression($_) } @$ops ] );
}


1;
