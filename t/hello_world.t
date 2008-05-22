use Test::More tests => 13;


use_ok('PIE::Evaluator');
use_ok('PIE::Builder');

package Hello;

use Moose;
use MooseX::AttributeHelpers;

has 'evaluator' => (
    is => 'rw',
    isa => 'PIE::Evaluator',
    lazy => 1,
    default => sub { return PIE::Evaluator->new()},
);

has 'rules' => (
#    metaclass => 'Collection::Array',
    is => 'rw',
    isa => 'ArrayRef',
#     provides  => {
#                 push       => 'push_rules'
#     },
#    default   => sub { [] },
    );




sub run { 
    my $self = shift;
    my $name = shift;

    for (@{$self->rules||[]}) {
        $self->evaluator->apply_script($_, 
                                       PIE::Expression::String->new( value => $name ));
        last unless ($self->evaluator->result->success);
        $name =  $self->evaluator->result->value;
    }   

    return "Hello $name";
}




package main;

is (Hello->new->run('jesse'),'Hello jesse');

my $hello = Hello->new;
isa_ok($hello => 'Hello');

use PIE::Lambda::Native;
$hello->evaluator->set_named('make-fred',
                             PIE::Lambda::Native->new( body => sub { return 'fred'}));
$hello->evaluator->set_named('make-bob', PIE::Lambda::Native->new( body => sub { my $name = shift; return 'bob'}));

$hello->evaluator->set_named('make-whoever',
                             PIE::Lambda::Native->new( body => sub { return $_[0] },
                                                       bindings => ['name'] ));


my $tree = [ [ 'make-fred'] ];
my $builder = PIE::Builder->new();
my $script = $builder->build_expressions($tree);
$script->bindings([ 'name' ]);

$hello->rules([ $script]);
can_ok($hello->rules->[0], 'evaluate');
is ($hello->run('jesse'),'Hello fred');

my $script2 = $builder->build_expressions([ ['make-bob'], ['make-fred'] ] );
$script2->bindings([ 'name' ]);
$hello->rules([ $script2 ]);
can_ok($hello->rules->[0], 'evaluate');

is ($hello->run('jesse'),'Hello fred');

my $script3 = $builder->build_expressions([ ['make-bob'] ]);
$script3->bindings([ 'name' ]);
my $script4 = $builder->build_expressions([ ['make-fred'] ]);
$script4->bindings([ 'name' ]);

$hello->rules([ $script3, $script4 ]);

can_ok($hello->rules->[0], 'evaluate');
can_ok($hello->rules->[1], 'evaluate');
is ($hello->run('jesse'),'Hello fred');


$hello->rules([ $hello->evaluator->get_named('make-whoever') ]);
can_ok($hello->rules->[0], 'evaluate');
is ($hello->run('jesse'),'Hello jesse');


1;
