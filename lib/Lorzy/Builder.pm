package Lorzy::Builder;
use Moose;
use Params::Validate;
use Lorzy::Lambda;
use Lorzy::Expression;

sub build_op_expression {
    my ($self, $name, $args) = @_;
    my $class = $name;
    $class = "Lorzy::Expression::$name" unless $name =~ /^Lorzy::Expression/;
    if ($class->can('meta')) {
        $name = $class;
    }
    else {
        $class = "Lorzy::Expression";
    }

    # XXX: in case of primitive-ops, we should only bulid the args we
    # know about

    my @known_args = $class eq 'Lorzy::Expression'
                   ? keys %$args
                   : keys %{ $class->signature };

    return $class->new(
        name         => $name,
        builder      => $self,
        builder_args => $args,
        args         => {
            map { $_ => $self->build_expression( $args->{$_} ) } @known_args
        },
    );
}

sub build_expression {
    my ($self, $tree) = @_;

    if (!ref($tree)) {
        return Lorzy::Expression::String->new(args => { value => $tree} );
    }
    elsif (ref($tree) eq 'HASH') {
        return $self->build_op_expression($tree->{name}, $tree->{args});
    } else {
        my $dump;

        # if they have YAML, use it
        if (eval { require YAML; 1 }) {
            $dump = YAML::Dump($tree);
        }
        # otherwise, go with the old fogey
        else {
            require Data::Dumper;
            $dump = Data::Dumper->Dump($tree);
        }

        confess "Invalid tree $tree. Expected string or hashref. Got $dump.";
    }
}

sub defun {
    my $self = shift;
    my %args = validate( @_, { ops => 1, signature => 1 });

    my $progn = Lorzy::Expression::ProgN->new(
        nodes => [map { $self->build_expression($_) } @{$args{ops}} ],
    );

    return Lorzy::Lambda->new(
        progn     => $progn,
        signature => $args{signature},
    );
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

