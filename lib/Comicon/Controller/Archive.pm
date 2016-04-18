package Comicon::Controller::Archive;
use Mojo::Base 'Mojolicious::Controller';

use autouse 'Data::Dump' => qw(dd pp);

sub view {
    my $self = shift;
    my $images = $self->app->home->list_files('public/comics/');
    $self->render( images => $images );
    return 1;
}

1;

__END__

=over 2

=item view()

This action renders the main archive view.

=back

Go back to L<Comicon>
