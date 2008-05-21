use Test::More qw/no_plan/;


use_ok('PIE::Evaluator');
use_ok('PIE::Builder');

package Hello;

use Moose;

has 'evaluator' => (
    is => 'rw',
    isa => 'PIE::Evaluator',
    lazy => 1,
    default => sub { return PIE::Evaluator->new()},
);

has 'rules' => (
    is => 'rw',
    isa => 'ArrayRef',

    );




sub run { 
    my $self = shift;
    my $name = shift;

    for (@{$self->rules||[]}) {
        $self->evaluator->run($_, name => $name);
        last unless ($self->evaluator->result->success);
        $name =  $self->evaluator->result->value;
    }   

    return "Hello $name";
}




package main;

is (Hello->new->run('jesse'),'Hello jesse');

my $hello = Hello->new;
isa_ok($hello => 'Hello');


$hello->evaluator->set_named('make-fred', sub { my $name = shift; return 'fred'});

my $tree = [ 'make-fred'];
my $builder = PIE::Builder->new();
my $script = $builder->build_expressions($tree);
$hello->rules([ $script]);
can_ok($hello->rules->[0], 'evaluate');
is ($hello->run('jesse'),'Hello fred');

1;
