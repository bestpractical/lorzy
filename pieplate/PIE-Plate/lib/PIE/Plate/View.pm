use warnings;
use strict;
package PIE::Plate::View;
use Jifty::View::Declare -base;
use JSON;

template 'index.html' => page {'hey'};
template 'lorzy' => page { 
    div { { id is 'result' }};
    div { { id is 'wrapper' } };
    div { { class is 'library' } };
 outs_raw('<style>#wrapper div { padding-left:1em;} </style>');
my $ops = [
            {   name => 'IfThen',
                args => {
                    'if_true'   =>  'hate',
                    'if_false'  => 'love',
                    'condition' => {
                        name => 'match-regexp',
                        args => {
                            regexp           => 'software',
                            'tested-string' => 'foo',
                        }
                    }
                }
            }
        ];

my $json_text   = JSON->new->encode($ops);

my $evaluator = PIE::Evaluator->new();
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

$evaluator->set_global_symbol( 'match-regexp' => $MATCH_REGEX );


my $signatures_json = JSON->new->encode(    $evaluator->core_expression_signatures());
my $symbol_sigs = JSON->new->encode($evaluator->symbol_signatures());

outs_raw(qq{<script type="text/javascript">


jQuery(lorzy_show($json_text));
jQuery(lorzy_show_symbols($symbol_sigs));
jQuery(lorzy_show_symbols($signatures_json));

</script>});

};


1;

