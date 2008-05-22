
package PIE::Expression;
use Moose;

with 'PIE::Evaluatable';    

has name => (
   is => 'ro',
   isa => 'Str');

has elements => (
   is => 'ro',
   isa => 'ArrayRef');

has args => (
    is => 'rw',
    default => sub { {} },
    isa => 'HashRef[PIE::Expression]');

#Attribute (args) does not pass the type constraint because: Validation failed for 'HashRef[PIE::FunctionArgument]' failed with value HASH(0x9a979c) at /opt/local/lib/perl5/site_perl/5.8.8/Moose/Meta/Attribute.pm line 340

# (foo bar (orz 1 ))
# === (eval 'foo bar (orz 1))
# === (apply foo ((bar (orz 1))



sub evaluate {
    my ($self, $ev) = @_;
    
    if ($self->elements) {
        # deprecated
        my $func = $self->elements->[0];
        my @exp = @{ $self->elements }[1..$#{ $self->elements }];
        my $lambda = $ev->resolve_name($func);
        return $ev->apply_script($lambda, @exp);
    }

    my $lambda = $ev->resolve_name($self->name);
    return $ev->apply_script_named_args( $lambda, $self->args );

    
}


package PIE::Expression::True;
use Moose;

extends 'PIE::Expression';

sub evaluate {1}

package PIE::Expression::False;
use Moose;
extends 'PIE::Expression::True';

sub evaluate {
    my $self = shift;
    return ! $self->SUPER::evaluate();

}

package PIE::Expression::Loop;
use Moose;
extends 'PIE::Expression';

has items => ( is => 'rw', isa => 'ArrayRef[PIE::Evaluatable]');
has block => ( is => 'rw', isa => 'PIE::Evaluatable');

sub evaluate {
    my $self = shift;

}

package PIE::Expression::IfThen;
use Moose;
extends 'PIE::Expression';


has condition => (
    is => 'rw',
    does => 'PIE::Evaluatable');
    
has if_true => (
    is => 'rw',
    does => 'PIE::Evaluatable');
    
has if_false => (
    is => 'rw',
    does => 'PIE::Evaluatable');
    

sub arguments { return qw(condition if_true if_false)} 
    

sub evaluate {
    my $self = shift;
    my $evaluator = shift;
    $evaluator->run($self->condition);
    

    if ($evaluator->result->value) {
        
        $evaluator->run($self->if_true);
        return $evaluator->result->value;
        }    else { 
        $evaluator->run($self->if_false);
        return $evaluator->result->value;
    }
}

package PIE::Expression::String;
use Moose;
extends 'PIE::Expression';

has value => (
    is => 'rw',
    isa => 'Str | Undef');
    
    
sub evaluate {
    my $self = shift;
    return $self->value;

}

package PIE::Expression::Symbol;
use Moose;
extends 'PIE::Expression';

has symbol => (
    is => 'rw',
    isa => 'Str');
    
    
sub evaluate {
    my ($self, $ev) = @_;
    my $result = $ev->get_named($self->symbol);
    return $result->isa('PIE::Expression') ? $ev->run($result) : $result; # XXX: figure out evaluation order here
}

1;
