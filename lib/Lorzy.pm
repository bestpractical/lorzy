
=head1 NAME

Lorzy - The Pinglin Interactive Evaluator

=head1 AUTHOR

Jesse and CL


=head1 LICENSE

Perl

=cut

package Lorzy;

use Lorzy::Builder;
use Lorzy::Evaluator;
use Lorzy::Lambda::Native;

sub evaluate {
    my $self    = shift;
    my $tree    = shift;
    my $builder = Lorzy::Builder->new;
    my $eval    = Lorzy::Evaluator->new;

    my $script = $builder->defun(ops => $tree, signature => {});
    $eval->apply_script($script, {});
    return $eval->result->value;
}

our $VERSION = 0;

1;
