package Lorzy::Expression::And;
use Moose;
extends 'Lorzy::Expression::ProgN';

sub evaluate {
    my ($self, $evaluator) = @_;
    warn "==> at and!";
    warn join(',',@{$self->nodes});
    for (@{$self->nodes}) {
        warn "==> eval $_ ";#.Dumper($_);use Data::Dumper;
        my $ret =$evaluator->evaluated_result($_);
#        my $ret = $_->evaluate($evaluator);
        warn $ret;
        $ret or return 0;
#        or return 0;
        warn "==> done $_";
    }
    return 1;
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

