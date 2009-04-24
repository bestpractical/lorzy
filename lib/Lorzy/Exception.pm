package Lorzy::Exception;
use Exception::Class
    ( 'Lorzy::Exception' =>
      { fields => ['details', 'stack'] },
      'Lorzy::Exception::Native' =>
      { isa => 'Lorzy::Exception'},
      'Lorzy::Exception::Loop' =>
      { isa => 'Lorzy::Exception',
        fields => ['instruction'] },
      'Lorzy::Exception::Params' =>
      { isa => 'Lorzy::Exception',
        fields => ['missing', 'unwanted'] },
   );


sub as_string {
    my $self = shift;
    "Lorzy: ".$self->message;
}

sub stack_as_string {
    my $self = shift;
    join("\n", (map { $_->name } reverse @{$self->stack}), '');
}

package Lorzy::Exception::Params;

sub as_string {
    my $self = shift;
    $self->message."\n".
        (@{$self->missing}  ? "The following arguments were missing: " . join(", ", @{$self->missing}) ."\n" : '').
        (@{$self->unwanted} ? "The following arguments were unwanted: " . join(", ", @{$self->unwanted})."\n" : '');
}

1;
