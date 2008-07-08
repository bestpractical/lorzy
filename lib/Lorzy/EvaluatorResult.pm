package Lorzy::EvaluatorResult;
use Moose;

has success => (
    is => 'rw',
    isa => 'Bool'
);

has error => ( 
    is => 'rw',
    

);

has value => ( 
    is => 'rw',
#    isa => 'Str | Undef | Lorzy::EvaluatorResult::RunTime',
    required => 0
    );


1;
