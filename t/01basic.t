use Test::More qw'no_plan';

use_ok('PIE::Expression');
use_ok('PIE::Evaluator');
use_ok('PIE::Lambda');
use_ok('PIE::Lambda::Native');
use_ok('PIE::Builder');

my $trivial = PIE::Expression::True->new;

my $evaluator = PIE::Evaluator->new;
ok ($evaluator->run($trivial));
ok($evaluator->result->success);
ok($evaluator->result->value);


my $false = PIE::Expression::False->new();
my $eval2 = PIE::Evaluator->new;
ok($eval2->run($false));
ok(!$eval2->result->value);
ok($eval2->result->success);


my $if_true = PIE::Expression::IfThen->new( condition => PIE::Expression::True->new(),                                           if_true => PIE::Expression::True->new(),if_false => PIE::Expression::False->new());
                                            
my $eval3 = PIE::Evaluator->new();
ok($eval3->run($if_true));
ok($eval3->result->value);
ok($eval2->result->success);

my $if_false = PIE::Expression::IfThen->new( condition => PIE::Expression::False->new(),                                           if_true => PIE::Expression::True->new(),if_false => PIE::Expression::False->new());
                                            
my $eval4 = PIE::Evaluator->new();
ok($eval4->run($if_false));
ok(!$eval4->result->value);
ok($eval4->result->success);





my $MATCH_REGEX =     PIE::Lambda::Native->new( body =>  sub { my ($arg, $regexp) = @_;
                                    return $arg =~ m/$regexp/; },
                            
                            bindings => [ 'tested-string', 'regex' ],
                            
                            );



my $eval5 = PIE::Evaluator->new;
$eval5->set_named( 'match-regexp' => $MATCH_REGEX);
    
                                    

my $match_p = PIE::Expression->new(elements => ['match-regexp',
                                                PIE::Expression::String->new( value => 'I do love software'), 
                                                PIE::Expression::String->new( value =>'software')]);

$eval5->run($match_p);
ok ($eval5->result->success);

is($eval5->result->value, 1);



my $eval6 = PIE::Evaluator->new();

$eval6->set_named( 'match-regexp' => $MATCH_REGEX);



my $match_fail_p = PIE::Expression->new(elements => ['match-regexp',
                                                PIE::Expression::String->new( value => 'I do love hardware'), 
                                                PIE::Expression::String->new( value =>'software')]);

$eval6->run($match_fail_p);
ok ($eval6->result->success);

ok(!$eval6->result->value);


my $script = PIE::Lambda->new(nodes => [ 
        PIE::Expression::True->new()

],

);

my $eval7 = PIE::Evaluator->new();
$eval7->apply_script($script);
ok($eval7->result->success);
ok($eval7->result->value);



my $script2 = PIE::Lambda->new(
    nodes => [
                $if_true ]);

my $eval8 = PIE::Evaluator->new();
$eval8->apply_script($script2);
ok($eval8->result->success);
ok($eval8->result->value);

my $eval9 = PIE::Evaluator->new();

$eval9->set_named( 'match-regexp' => $MATCH_REGEX);



my $match_script = PIE::Lambda->new(

    nodes => [
        PIE::Expression->new(
            elements => [
                'match-regexp',
                PIE::Expression::Symbol->new( symbol => 'tested-string' ),
                PIE::Expression::Symbol->new( symbol => 'regex' ),
            ]
        )
    ],
    bindings => [ 'tested-string', 'regex' ],
);


$eval9->apply_script($match_script,                                                 PIE::Expression::String->new( value => 'I do love hardware'), 
                                                PIE::Expression::String->new( value =>'software') );

ok ($eval9->result->success);

is($eval9->result->value, 1);
my $tree = 
[
          {
            name => 'IfThen',
            args => {
                          'if_true' => 'hate',
                          'if_false' => 'love',
                          'condition' => [ 'match-regexp', 'software', 'foo' ],
                        }
          }
        ];


my $builder = PIE::Builder->new();
#use YAML;

my $eval10 = PIE::Evaluator->new();

$eval10->set_named( 'match-regexp' => $MATCH_REGEX);


$eval10->apply_script( $builder->build_expressions($tree) );
ok($eval10->result->success);
is($eval10->result->value,'love');


