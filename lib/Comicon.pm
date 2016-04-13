package Comicon;
use Mojo::Base 'Mojolicious';

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->secrets(['55128abf-2abf-44de-92fc-0d1634d4f70b']);

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get(q{/})->to('main#comic');
    $r->post('/new')->to('image#generate');
    return 1;
}

1;

__END__

=encoding utf8

=head1 NAME

Comicon - Comic Constructor.

=head1 VERSION

This is version 3.

=head1 SYNOPSIS

This application renders comic strips with random images and random text, for
an emotional impact.

=head1 DESCRIPTION

This application is built as a L<Mojolicious> application.

=head1 SUBROUTINES/METHODS

TBD

=head1 DIAGNOSTICS

Check the log/ directory for development.log or production.log, depending on
the mode you are running the application in.

=head1 CONFIGURATION AND ENVIRONMENT

TBD

=head1 DEPENDENCIES

=over

=item L<Image::Magick>

=back

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

Several. (TBD).

=head1 AUTHOR

Pär Karlsson <feinorgh [at] gmail [dot] com>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2016  Pär Karlsson

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see L<http://www.gnu.org/licenses/>.
