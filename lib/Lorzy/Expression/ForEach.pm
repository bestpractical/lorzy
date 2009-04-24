package Lorzy::Expression::ForEach;
use Moose;
use MooseX::ClassAttribute;
extends 'Lorzy::Expression';

class_has signature => (
    is      => 'ro',
    default => sub {
        return {
            list => Lorzy::FunctionArgument->new(
                name => 'list',
            ),
            binding => Lorzy::FunctionArgument->new(
                name => 'Str',
            ),
            do => Lorzy::FunctionArgument->new(
                name => 'Str',
                type => 'Lorzy::Lambda', # XXX: type for runtime?
            ),
        };
    },
);

sub evaluate {
    my ($self, $evaluator) = @_;

    my $lambda  = $self->args->{do}->evaluate($evaluator);
    my $binding = $self->args->{binding}->evaluate($evaluator);
    my $list    = $self->args->{list}->evaluate($evaluator);

    die "Invalid do-block $lambda" unless $lambda->isa("Lorzy::Lambda");
    die "Invalid 'list' $list" unless ref($list) eq 'Lorzy::EvaluatorResult::RunTime';

    my $nodes = $$list;

    foreach (@$nodes) {
        eval {
            $lambda->apply($evaluator, { $binding => $_ });
        };
        my $e;
        if ($e = Lorzy::Exception::Loop->caught()) {
            last if $e->instruction eq 'break';
            next if $e->instruction eq 'continue';
            $evaluator->throw_exception( 'Lorzy::Exception' => 'Unknown loop instruction: '.$e->instruction );
        }
        elsif ($e = Lorzy::Exception->caught()) {
            ref $e ? $e->rethrow : die $e;
        }
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

