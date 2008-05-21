
package PIE::EvaluatorResult;
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
    isa => 'Str | Undef',
    required => 0
    );


1;
