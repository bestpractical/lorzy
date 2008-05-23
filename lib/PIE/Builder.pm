
package PIE::Builder;
use Moose;
use Params::Validate;
use PIE::Lambda;

use PIE::Expression;
use UNIVERSAL::require;

sub build_op_expression {
    my ($self, $name, $args) = @_;
    my $class = "PIE::Expression::$name";
    $class->require;
    if($class->can('meta')){
        die unless $class->meta->does_role("PIE::Evaluatable");
        return    $class->new( map { $_ => $self->build_expression( $args->{$_} ) } keys %$args );
    }
    else {
        return PIE::Expression->new( name => $name, args => { map { $_ => $self->build_expression( $args->{$_} ) } keys %$args } );
    }
}

sub build_expression {
    my ($self, $tree) = @_;
    if (!ref($tree)) {
        return PIE::Expression::String->new(value => $tree );
    }
    elsif (ref($tree) eq 'HASH') {
        return $self->build_op_expression($tree->{name}, $tree->{args});
    } else {
        Carp::confess("Don't know what to do with a tree that looksl ike ". YAML::Dump($tree));
    }
}


sub defun {
    my $self = shift;
    my %args = validate( @_, { ops => 1, args => 1 });
    return PIE::Lambda->new( nodes => [map { $self->build_expression($_) } @{$args{ops}} ], args => $args{args} );
}

1;
