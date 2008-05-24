package PIE::Plate::Action::RunL;
use PIE::Lambda;
use PIE::Lambda::Native;
use PIE::Builder; use PIE::FunctionArgument;
use PIE::Evaluator; use JSON;
use Jifty::Param::Schema;
use PIE::Plate::Action schema {
    param struct => type is 'text';
};


sub take_action {
    my $self = shift;
    warn $self->argument_value('struct');
    my $tree = JSON::from_json($self->argument_value('struct'));
    my $builder = PIE::Builder->new();
    my $eval = PIE::Evaluator->new();


my $MATCH_REGEX = PIE::Lambda::Native->new(
    body => sub {
        my $args = shift;
        my $arg = $args->{'tested-string'};
        my $regex = $args->{'regexp'};

        return $arg =~ m/$regex/;
    },

    signature => {
           'tested-string' =>  PIE::FunctionArgument->new( name =>              'tested-string' =>  type => 'Str' ),
           'regexp'=>  PIE::FunctionArgument->new( name =>      'regex', type => 'Str' )
    }

);
$eval->set_global_symbol( 'match-regexp' => $MATCH_REGEX );


    my $script  = $builder->defun( ops => $tree, signature => {});
    eval { $eval->apply_script($script, {} )};
    if (my $msg = $@) { 
        $self->result->error($msg);
    }else {
    warn $eval->result->value, $eval->result->success ;

    $self->result->message($eval->result->value);
   $eval->result->success ||  $eval->result->error($eval->result->error);
}
}

1;
