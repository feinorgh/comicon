package Comicon::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use utf8;

# This action renders the default comic view
sub comic {
    my $self = shift;
    $self->render( msg => $self->app->config('data_dir') );
    return 1;
}

# Show the help page (main/help.html.ep)
sub help {
    my $self = shift;
    $self->render;
    return 1;
}

1;

__END__

=over 4

=item comic()

The comic action renders the default comic strip view

=item help()

This method displays the user help page.

=back

Go back to L<Comicon>
