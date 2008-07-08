package Lorzy::Lambda;
use Moose;
use MooseX::Params::Validate;

with 'Lorzy::Block';

has progn => (
    is      => 'ro',
    isa     => 'Lorzy::Expression::ProgN',
    default => sub { Lorzy::Expression::ProgN->new },
    handles => [qw(nodes)],
);

has signature => (
    is      => 'rw',
    default => sub { {} },
    isa     => 'HashRef[Lorzy::FunctionArgument]',
);

sub check_args {
    my $self = shift;
    my $passed = shift; #reference to hash of provided args
    my $expected = $self->signature; # expected args

    my $missing = {};
    my $unwanted = {};

    my $fail = 0;
    foreach my $arg (keys %$passed) {
        if (!$expected->{$arg}) {
            $unwanted->{$arg} = "The caller passed $arg which we were not expecting" ;
        }
    }

    foreach my $arg (keys %$expected) {
        if (!$passed->{$arg}) {
            $missing->{$arg} =  "The caller did not pass $arg which we require";
        }
    }

    return ($missing, $unwanted);
}

sub validate_args_or_die {
    my $self = shift;
    my $args = shift;
    my ($missing, $unwanted) = $self->check_args($args);

    if (keys %$missing || keys %$unwanted) {
        die "Function signature mismatch \n"
          . (keys %$missing  ? "The following arguments were missing: " . join(", ", keys %$missing) ."\n" : '')
          . (keys %$unwanted ? "The following arguments were unwanted: " . join(", ", keys %$unwanted)."\n" : '');
    }
}

sub apply {
    my ($self, $evaluator, $args) = @_;

    $self->validate_args_or_die($args);

    $evaluator->enter_stack_frame(args => $args, block => $self);
    my $res = $self->progn->evaluate($evaluator);

    $evaluator->leave_stack_frame;
    return $res;
}

1;

