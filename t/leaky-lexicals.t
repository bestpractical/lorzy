use Test::More tests => 6;

use_ok('PIE::Evaluator');
use_ok('PIE::Builder');
use_ok('PIE::FunctionArgument');
use_ok('PIE::Lambda::Native');
my $evaluator = PIE::Evaluator->new();
$evaluator->set_named( 'make-fred', PIE::Lambda::Native->new( body => sub { return 'fred' } ) );
$evaluator->set_named( 'make-bob', PIE::Lambda::Native->new( body => sub { return 'bob' } ) );

my $args = { name => PIE::Expression::String->new( args => { value => 'Hiro' } ) };






my $builder = PIE::Builder->new();

my $script3 = $builder->defun( ops => [ { name => 'make-bob' } ],
    signature => { name => PIE::FunctionArgument->new( name => 'name', type => 'Str' ) }
);
my %before = %{ $evaluator->named};
$evaluator->apply_script( $script3, $args);
my %after = %{ $evaluator->named};
is($evaluator->result->value,'bob');
is_deeply(\%before => \%after);

