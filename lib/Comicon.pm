package Comicon;
use Mojo::Base 'Mojolicious';
use English qw(-no_match_vars);
use Comicon::Schema;
use aliased 'DBIx::Class::DeploymentHandler' => 'DH';

my $_db;

has db => sub {
    my $self = shift;
    if (!defined $_db) {
        my $config = $self->plugin('Config');
        $self->app->log->debug("Connecting to $config->{database}{dsn}...");
        $_db = Comicon::Schema->connect(
            $config->{database}{dsn},
            $config->{database}{username},
            $config->{database}{password},
            $config->{database}{dbi_attr},
        ) or $self->app->log->error("Could not connect to database: $ERRNO");
        my $dh = DH->new(
            {
                schema => $_db,
                force_overwrite => 1,
                sql_translator_args => { add_drop_table => 0 },
            }
        );
        if ( $dh->version_storage_is_installed ) {
            $dh->prepare_deploy;
            $dh->prepare_upgrade;
            $dh->upgrade;
        }
        else {
            $dh->prepare_install;
            $dh->install;
        }
    }
    return $_db;
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->secrets( ['55128abf-2abf-44de-92fc-0d1634d4f70b'] );

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');

    my $config = $self->plugin('Config');

    # get the Comic text plugin too
    $self->plugin('Comicon::Text');

    if ( $self->app->mode eq 'production' ) {
        $self->app->hook(
            before_dispatch => sub {
                my $c = shift;
                push @{ $c->req->url->base->path->trailing_slash(1) },
                  shift @{ $c->req->url->path->leading_slash(0) };
            }
        );
    }

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get(
        q{/} => sub {
            my $self = shift;
            $self->redirect_to(q{/comic});
            return 1;
        }
    );
    $r->get('/comic')->to('main#comic');
    $r->get('/comic/#id')->to('main#comic');
    $r->post('/comic/#id')->to('main#save');
    $r->get('/archive')->to('archive#view');
    $r->get('/help')->to('main#help');
    $r->get('/strip')->to('strip#get_frames');
    return 1;
}

1;

__END__

=encoding utf8

=head1 NAME

Comicon

L<Comicon|..> - B<Comi>c B<Con>structor.

=head1 VERSION

This is version 3, built from the ashes of two earlier incarnations.

=head1 SYNOPSIS

This application renders comic strips with random images and random text, for
(hopefully) an emotional or humorous effect.

It is intended mostly as a demonstration for using
L<Mojolicious|http://mojolicio.us>, L<bootstrap|http://getbootstrap.com/> and
L<AngularJS|https://angularjs.org/> in one and the same web application.

=head1 DESCRIPTION

This application is built as a L<Mojolicious> application. It is only meant
as a demo for building a web application with Mojolicious, AngularJS and
bootstrap.

The videos included in this demo are all taken from Archive.org (L<https://archive.org/>) and are in the public domain.

=head1 SUBROUTINES/METHODS

=over 2

=item startup()

Runs once at server start up, and initializes the application.

=back

=head1 MODULES/CONTROLLERS

=over 2

=item L<Comicon::Controller::Main>

The main controller for the application.

=item L<Comicon::Controller::Archive>

The controller for the archived comic strips.

=item L<Comicon::Text>

A class for generating suitable text for the comic strips.

=back

=head1 DIAGNOSTICS

Check the log/ directory for development.log or production.log, depending on
the mode you are running the application in.

=head1 CONFIGURATION AND ENVIRONMENT

The application is configured from one file in the root directory of the
distribution, C<comicon.conf>.

=over 2

=item C<data_dir = app-E<gt>home-E<gt>rel_dir('data')>

The C<$data_dir/video> directory is where the application looks for movie files.

=item C<font>

This configuration item is currenly not used (it's a hashref, describing a
TrueType (tm) name and a font size).

=back

Currently you can set the data directory where the material for the frames
reside.

=head1 DEPENDENCIES

=over 2

=item L<Image::Magick>

Image::Magick is needed for the image manipulation routines. It should be
included with the operating system of your choice, or you can compile it
yourself from the sources. Make sure you install the Perl bindings for the
ImageMagick package for your Perl environment.

See L<http://www.imagemagick.org/>

=item L<Math::Random>

This is a Perl port of the C randlib library.

See L<Math::Random|https://metacpan.org/pod/Math::Random> for details.

=back

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

=over 2

=item No serialization

Currently the comic texts are not serialized with the images

=item Wacky text positioning

Depending on your window size, text frames may end up outside the image area.

=item Whoa, boring!

The texts are, frankly, not that creative or smart.

=back

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
