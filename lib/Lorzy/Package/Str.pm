package Lorzy::Package::Str;
use base 'Lorzy::Package';

__PACKAGE__->defun( 'Eq',
    signature => {
        'arg1' => Lorzy::FunctionArgument->new( name => 'arg1', type => 'Str'),
        'arg2' => Lorzy::FunctionArgument->new( name => 'arg2', type => 'Str' )
        },
    native => sub {
        my $args = shift;
        return ($args->{arg1} eq $args->{arg2});
    },
);

1;
