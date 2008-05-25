use Test::More tests => 13;
use strict;
use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Builder');
use_ok('PIE::Lambda::Native');
use_ok('PIE::FunctionArgument');
use Test::Exception;

my $MATCH_REGEX = PIE::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg    = $args->{'tested-string'};
        my $regexp = $args->{'regexp'};
        return ($arg =~ m/$regexp/ )? 1 : 0;
    },

    signature => {
        'tested-string' => PIE::FunctionArgument->new( name => 'tested-string' => type => 'Str'),
        'regexp' => PIE::FunctionArgument->new( name => 'regexp', type => 'Str' )
        }

);

my $builder = PIE::Builder->new();
my $eval = PIE::Evaluator->new();
$eval->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

my $script =
    $builder->defun(
    ops => [
        { name => 'Let',
            args => {
                bindings => { REGEXP => 'software' },
                nodes => [
                    { name => 'IfThen',
                        args => {
                            'if_true'   => 'hate',
                            'if_false'  => 'love',
                            'condition' => {
                                name => 'match-regexp',
                                args => {
                                    regexp => { name => 'Symbol', args => { symbol => 'REGEXP' } },
                                    'tested-string' => 
                                         { name => 'Symbol', args => { symbol => 'tested-string' } },
                                    }
                                }
                            }
                    }
                    ] } } ],
    signature => { 'tested-string' => PIE::FunctionArgument->new( name => 'tested-string' => type => 'Str' ) },
    );

is(scalar @{$script->progn->nodes}, 1);
isa_ok($script->progn->nodes->[0], 'PIE::Expression::Let');
is(scalar @{$script->progn->nodes->[0]->nodes}, 1);

ok(exists $script->progn->nodes->[0]->bindings->{REGEXP});
isa_ok($script->progn->nodes->[0]->bindings->{REGEXP}, 'PIE::Expression');

TODO: {
    local $TODO = 'lexical loopup in outter blocks';
lives_ok {
$eval->apply_script( $script, { 'tested-string', 'you do love software' } );
};
ok( $eval->result->success, $eval->result->error );
is( $eval->result->value, 'hate' );
};
