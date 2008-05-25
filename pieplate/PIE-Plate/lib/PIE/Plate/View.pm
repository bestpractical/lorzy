use warnings;
use strict;
package PIE::Plate::View;
use Jifty::View::Declare -base;
use JSON;

template 'index.html' => page {'hey'};
template 'lorzy' => page { 
    div { { id is 'result' }};
    div { { id is 'wrapper' } };
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

my $signatures_json = JSON->new->encode(    $evaluator->builtin_signatures());


outs_raw(qq{<script type="text/javascript">

var builtins = $signatures_json;

jQuery(lorzy_show($json_text));

</script>});

};


1;

