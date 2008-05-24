package PIE::Plate::View;
use Jifty::View::Declare -base;
use JSON;

template 'index.html' => page {'hey'};
template 'lorzy' => page { 

    div { { id is 'wrapper' } };
 outs_raw('<style>#wrapper div { padding-left:1em;} </style>');
my $ops = [
            {  name => 'hateyou', args => {}},

            {   name => 'IfThen',
                args => {
                    'if_true'   =>  { 
                                    name => 'progn',
                                    nodes => [
                                            { name => 'IsTrue', args => {}}, 
                                            { name => 'IsFalse', args => {}},
                                            { name => 'IsTrue', args => {}}


                                    ]


                    },
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


outs_raw(qq{<script type="text/javascript">

jQuery(lorzy_show($json_text));

</script>});

};


1;

