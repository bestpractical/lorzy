package Lorzy::EvaluatorResult;
use Moose;

has success => (
    is  => 'rw',
    isa => 'Bool',
);

has error => (
    is => 'rw',
);

has value => (
    is  => 'rw',
#   isa => 'Str | Undef | Lorzy::EvaluatorResult::RunTime',
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

