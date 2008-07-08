use Test::More tests => 13;
use strict;
use_ok('Lorzy::Expression');
use_ok('Lorzy::Evaluator');
use_ok('Lorzy::Builder');
use_ok('Lorzy::Lambda::Native');
use_ok('Lorzy::FunctionArgument');
use Test::Exception;

my $MATCH_REGEX = Lorzy::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg    = $args->{'tested-string'};
        my $regexp = $args->{'regexp'};
        return ($arg =~ m/$regexp/ )? 1 : 0;
    },

    signature => {
        'tested-string' => Lorzy::FunctionArgument->new( name => 'tested-string' => type => 'Str'),
        'regexp' => Lorzy::FunctionArgument->new( name => 'regexp', type => 'Str' )
        }

);

my $builder = Lorzy::Builder->new();
my $eval = Lorzy::Evaluator->new();
$eval->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

my $script =
    $builder->defun( # outer block
    ops => [
        { name => 'Let', #inner block. each block has a lexical pad structure
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
                                         { name => 'Symbol', args => { symbol => 'tested-string' } }, # lookup to tested string needs to query the outer block's lexpad
                                    }
                                }
                            }
                    }
                    ] } } ],
    signature => { 'tested-string' => Lorzy::FunctionArgument->new( name => 'tested-string' => type => 'Str' ) },
    );

is(scalar @{$script->progn->nodes}, 1);
isa_ok($script->progn->nodes->[0], 'Lorzy::Expression::Let');
is(scalar @{$script->progn->nodes->[0]->nodes}, 1);

ok(exists $script->progn->nodes->[0]->bindings->{REGEXP});
isa_ok($script->progn->nodes->[0]->bindings->{REGEXP}, 'Lorzy::Expression');


lives_ok {
    $eval->apply_script( $script, { 'tested-string', 'you do love software' } );
};
ok( $eval->result->success, $eval->result->error );
is( $eval->result->value, 'hate' );

