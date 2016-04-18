package Comicon::Text;
use Modern::Perl;
use utf8;

use base 'Mojolicious::Plugin';

our $VERSION = 1.00;

# this function generates an array with texts containing as many members
# as is given by framecount
sub get_texts {
    my ( $self, $framecount ) = @_;
    my @texts;
    for my $frame ( 1 .. $framecount ) {
        push @texts, "This is frame $frame";
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
