package Lorzy::FunctionArgument;
use Moose;



has name => (
    is => 'rw',
    isa => 'Str'    
);


has type => (
    is => 'rw',
    isa => 'Str'# I want an enum of String, Number, Undef, Lorzy::Expression..what else?
);

has description => (
    is => 'rw',
    isa => 'Str | Undef',
    required => 0);

1;
