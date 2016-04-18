package Comicon::Text;
use Modern::Perl;
use utf8;

use base 'Mojolicious::Plugin';

our $VERSION = 1.00;

sub get_adverb {
    my @adverbs = qw(
        obviously sadly happily gloriously surprisingly
    );
    return $adverbs[int rand @adverbs];
}

sub get_start {
    my @starts = (
        'So there I was',
        'This day started like any other',
        'Monday morning...',
        'Here I am',
        'Such an awesome thing',
    );
    return $starts[int rand @starts];
}

sub get_middle {
    my @middles = (
        'One night to be confused',
        'Under the influence',
        'To know what to say',
        'Would it be good enough?',
        'But the law is the law',
        'Just standing there',
        'Looking sharp',
        'A silver lining',
        'I thought I knew what I was missing',
    );
    return $middles[int rand @middles];
}

sub get_ending {
    my @endings = (
        'But, ' . get_adverb() . ', they didn\'t fall for that.',
        'Well, I should have known better.',
        'Maybe next time.',
        'I guess they called the bluff.',
        'Sometimes everything just seems black and white.',
        'Is this really it?',
    );
    return $endings[int rand @endings];
}

# this function generates an array with texts containing as many members
# as is given by framecount
sub get_texts {
    my ( $self, $framecount ) = @_;
    my @texts;
    for my $frame ( 1 .. $framecount ) {
        if ( $frame == 1 ) {
            push @texts, get_start();
        }
        elsif ( $frame == $framecount ) {
            push @texts, get_ending();
        }
        else {
            push @texts, get_middle();
        }
    }
    return \@texts;
}

sub register {
    my ( $self, $app ) = @_;
    $app->helper( get_texts => \&get_texts );
    return 1;
}

1;

__END__

=encoding utf-8

=head1 METHODS

=over 2

=item register()

This method is required to register as a plugin to Mojolicious

=item get_texts( $count )

This method returns an array of size $count with texts.

=back

Go back to L<Comicon>
