package PIE::Plate::View;
use Jifty::View::Declare -base;
use JSON;

template 'index.html' => page {'hey'};
template 'lorzy' => page { 

my $ops = [
            {   name => 'IfThen',
                args => {
                    'if_true'   => 'hate',
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

lorzy_show($json_text);

</script>});

};


1;
