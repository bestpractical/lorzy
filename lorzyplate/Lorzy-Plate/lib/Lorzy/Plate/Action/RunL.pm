package Lorzy::Plate::Action::RunL;
use Lorzy;
use JSON;

use Jifty::Param::Schema;
use Lorzy::Plate::Action schema {
    param struct => type is 'text';
};

sub take_action {
    my $self = shift;
    my $tree = JSON::from_json($self->argument_value('struct'));

    my $MATCH_REGEX = Lorzy::Lambda::Native->new(
        body => sub {
            my $args  = shift;
            my $arg   = $args->{'tested-string'};
            my $regex = $args->{'regexp'};
            return $arg =~ m/$regex/;
        },
        signature => {
           'tested-string' => Lorzy::FunctionArgument->new(
               name => 'tested-string',
               type => 'Str',
           ),
           'regexp' => Lorzy::FunctionArgument->new(
               name => 'regex',
               type => 'Str',
           ),
        }
    );

    my $eval = Lorzy::Evaluator->new;
    $eval->set_global_symbol( 'match-regexp' => $MATCH_REGEX );

    eval {
        my $builder = Lorzy::Builder->new;
        my $script  = $builder->defun(ops => $tree, signature => {});
        $eval->apply_script($script, {});
    };

    if (my $msg = $@) {
        $self->result->error($msg);
    } else {
        $self->result->message($eval->result->value);
    }
}

1;

