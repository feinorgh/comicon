package Comicon::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

# This action renders the default comic view

sub comic {
    my $self = shift;
    $self->render;
    return 1;
}

1;

__END__

=over 4

=item comic()

The comic action renders the default comic strip view

=back
