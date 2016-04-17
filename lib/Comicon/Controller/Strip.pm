package Comicon::Controller::Strip;
use Mojo::Base 'Mojolicious::Controller';

use utf8;
use DateTime;
use DateTime::Duration;
use English qw(-no_match_vars);
use File::Find::Rule;
use File::Temp;
use IPC::Run qw(run timeout);
use Image::Magick;
use Math::Random;
use Path::Class;
use Readonly;

use autouse 'Data::Dump' => qw(dd pp);

Readonly my $DEFAULT_TIMEOUT => 10; # seconds
Readonly my $DEFAULT_MINJUMP => 5;  # at least these many frames between each
Readonly my %RE              => (
    duration => qr{
        length:\s+(?<frames>\d+)\sframes,
        .*?duration.*?
        (?<hours>\d+):(?<minutes>\d+):(?<seconds>\d+)
    }imsx,
    moviefile => qr{
        [.](?:avi|mpe?g|mkv|mov|mp4)\z
    }imsx,
);

my %program = (
    mplayer => {
        exe => '/usr/bin/mplayer',
        opt =>
          '-ao null -really-quiet -frames 1 -msglevel all=1 >/dev/null 2>&1',
    },
    tcprobe => {
        exe => '/usr/bin/tcprobe',
    },
    mkvinfo => {
        exe => '/usr/bin/mkvinfo',
    },
);


# this action builds a series of frames to use in a comic strip
# and returns the information regarding each frame in a JSON
# structure according to http://jsonapi.org/
sub get_frames {
    my $self = shift;

    # this will generate 1-5 frames, with a heavy emphasis on
    # 3 frames, sometimes 2 or 4 frames and very seldom 1 or 5 frames
    # if the user has supplied a number of frames via a parameter, we
    # use that number instead
    my $framecount =
      $self->param('frames') || int random_normal( 1, 3.5, 0.42 );
    my $texts     = $self->get_texts($framecount);
    my $moviefile = $self->get_movie();

    my @command;
    if ( $moviefile =~ m/[.]mkv\z/imsx ) {

        # matroska containers can't be read by tcprobe
        @command = ( $program{mkvinfo}{exe}, $moviefile );
    }
    else {
        @command = ( $program{tcprobe}{exe}, '-d 0', '-i', $moviefile );
    }
    $self->app->log->debug("Getting movie data for '$moviefile':");
    my ( $in, $out, $err );
    $self->app->log->debug( 'Running \'' . join( q{ }, @command ) . q{'.} );
    run \@command, \$in, \$out, \$err, timeout($DEFAULT_TIMEOUT);

    my $seconds;

    my $now = DateTime->now( time_zone => 'UTC' );
    if ( $out =~ $RE{duration} ) {
        my %m        = %LAST_PAREN_MATCH;
        my $duration = DateTime::Duration->new(
            hours   => $m{hours},
            minutes => $m{minutes},
            seconds => $m{seconds},
        );
        my $later = $now->clone->add_duration($duration);
        $seconds = $later->subtract_datetime_absolute($now)->seconds;
        $self->app->log->debug("Duration: $seconds seconds");
    }
    else {
        $self->app->log->error("Could not parse time data from output: '$out'");
    }

    # get a random delta to jump for each frame
    my $delta = int random_uniform( 1, 5, 15 );

    # begin by selecting a random frame and build a one-member array
    my @frames = ( int random_uniform( 1, 0, $seconds ) );
    my $current_frame = $frames[0];
    while ( @frames < $framecount ) {
        push @frames, int( $current_frame + ( random_uniform() * $delta ) + $DEFAULT_MINJUMP );

        # let the current frame be the last one in the array
        $current_frame = $frames[-1];
    }

    my @imagesize   = ( 1000, 300 );
    my $padding     = 10;
    my $textpadding = 2;
    my @coords      = ( $padding, $padding );

    # determine the width of each frame
    my $imagewidth =
      ( $imagesize[0] - $padding - $framecount * $padding ) / $framecount;
    my $imageheight = ( $imagesize[1] - $padding * 2 );
    my $imageaspect = $imagewidth / $imageheight;
    my $strip       = Image::Magick->new( size => join( q{x}, @imagesize ) );
    $strip->ReadImage('canvas:black');
    my @stripsize   = split m/x/msx, $strip->Get('size');
    my $mplayerdir  = File::Temp->newdir();
    my $tempdirname = $mplayerdir->dirname;
    my $mplayerfile = file( $tempdirname, '00000001.png' );

    my $ratio;
    for my $f (@frames) {
        my $command = <<"_TEXT_";
$program{mplayer}{exe} -really-quiet -ao null -frames 1 -msglevel all=1 -vo png:outdir=$tempdirname -ss $f
_TEXT_
        my @cmd = split m/\s/msx, $command;
        push @cmd, $moviefile;
        $self->app->log->debug( 'Running: \'' . join( q{ }, @cmd ) . q{'} );
        run \@cmd, \$in, \$out, \$err, timeout($DEFAULT_TIMEOUT);
        my $img      = Image::Magick->new;
        my $filename = $mplayerfile->stringify;
        my $x        = $img->Read($filename);
        if ($x) {
            $self->app->log->error("Image::Magick error '$x'");
        }
        my $imgwidth  = $img->Get('width');
        my $imgheight = $img->Get('height');
        my $origratio = $imgwidth / $imgheight;
        if ( !$ratio ) {
            my $w      = $img->Get('width');
            my $h      = $img->Get('height');
            my $aspect = $w / $h;
            if ( $imageaspect > $aspect ) {
                $ratio = $stripsize[0] / $w;
            }
            else {
                $ratio = $stripsize[1] / $h;
            }
        }
        my $newsize = join q{x}, ( $imgwidth * $ratio, $imgheight * $ratio );
        $x = $img->AdaptiveResize( geometry => $newsize, filter => 'Lanczos' );
        if ($x) {
            $self->app->log->error("Image::Magick error '$x'");
        }
        $imgwidth  = $img->get('width');
        $imgheight = $img->get('height');
        if ( $imgwidth > $imagewidth || $imgheight > $imageheight ) {
            $x = $img->Crop(
                width   => $imagewidth,
                height  => $imageheight,
                gravity => 'Center',
            );
            if ($x) {
                $self->app->log->error("Image::Magick error '$x'");
            }
        }
        $x = $strip->Composite(
            image   => $img,
            compose => 'Over',
            x       => $coords[0],
            y       => $coords[1],
        );
        if ($x) {
            $self->app->log->error("Image::Magick error '$x'");
        }
        undef $img;
        $coords[0] = $coords[0] + $imagewidth + $padding;
    }

    my $basename = $now->iso8601;
    my $outname  = "comics/$basename.png";
    my $x        = $strip->Write("public/$outname");
    if ($x) {
        $self->app->log->error("Image::Magick error '$x'");
    }

    $self->render(
        json => {
            data => {
                movie    => $moviefile,
                in       => $in,
                out      => $out,
                err      => $err,
                duration => $seconds,
                image    => $self->url_for($outname),
                frames   => scalar @frames,
                texts    => $texts,
            },
        },
    );
    return 1;
}

# returns a random movie filename from a directory of movies
sub get_movie {
    my $self = shift;
    my $video_dir = dir( $self->app->config('data_dir'), 'videos' );
    $self->app->log->debug("Looking for videos in '$video_dir'");
    my @files =
      File::Find::Rule->file()->name( $RE{moviefile} )->in("$video_dir");
    $self->app->log->debug( 'Found ' . @files . ' videos.' );
    return $files[ int rand @files ];
}

1;

__END__

=encoding utf-8

=head1 METHODS

=over 2

=item get_movie()

Gets a filename for a movie based on what is in $RE{moviefile}.

=item get_frames()

Gets data in JSON format for a constructed comic strip image.

=back

