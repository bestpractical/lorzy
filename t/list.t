use Test::More tests => 6;
use strict;
use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Builder');
use_ok('PIE::Lambda::Native');
use_ok('PIE::FunctionArgument');
use Test::Exception;
my $builder = PIE::Builder->new();
my $eval = PIE::Evaluator->new();

my $script =
    $builder->defun(
    ops => [
        { name => 'List',
            args => {
                nodes => [
                     "hate",
                     "love",
                     "hate"  ] } } ],
    signature => { });

$eval->set_global_symbol( 'get-list' => $script );

my @remembered;
$eval->set_global_symbol( 'remember' =>
PIE::Lambda::Native->new(
    body => sub {
        my $args = shift;
        push @remembered, $args->{what};
        return 1;
    },

    signature => {
        'what' => PIE::FunctionArgument->new( name => 'what' => type => 'Str'),
        }

) );


$eval->apply_script(
    $builder->defun(
    ops => [
        { name => 'ForEach',
            args => {
                list => { name => 'get-list', args => {} },
                binding => 'what',
                do => { name => 'Symbol', args => { symbol => 'remember'} }
                    }
        } ],
    signature => { }),
 {});

is_deeply(\@remembered, ['hate', 'love', 'hate']);
