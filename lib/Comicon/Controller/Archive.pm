package Comicon::Controller::Archive;
use Mojo::Base 'Mojolicious::Controller';

sub view {
    my $self = shift;
    $self->render;
    return 1;
}

1;

__END__

=over 2

=item view()

This action renders the main archive view.

=back

Go back to L<Comicon>
