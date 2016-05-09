package Comicon::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';
use utf8;

# This action renders the default comic view
sub comic {
    my $self = shift;
    my $id   = $self->param('id');
    $self->app->log->debug("Showing comic id '$id'");
    $self->render( msg => $self->app->config('data_dir') );
    return 1;
}

sub save {
    my $self = shift;
    my $id   = $self->param('id');
    $self->app->log->debug("Saving comic id '$id'");
    my $comic_rs = $self->app->db;
    my $data = {
        data => [
            type => 'comic',
            id   => 1,
        ]
    };
    $self->render( json => $data );
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
