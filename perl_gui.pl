use Tk;
use Tk::JPEG;
use Tk::Pane;
use strict;
use warnings;

my $dir = shift || '.';

chdir $dir or die "Can't go do $dir - $!\n";

my $filespec = "*.jpg";
my @files = glob $filespec
or die "No files matching $filespec in $dir !\n";
my $ii = -1; # image index

my $mw = new MainWindow;

my $scrolled = $mw
    ->Scrolled( 'Pane', -scrollbars => 'osoe', -width => 640, -height => 480, )
    ->pack( -expand => 1, -fill => 'both', );

my $imagit = $scrolled
    ->Label
    ->pack( -expand => 1, -fill => 'both', );

my( $xscroll, $yscroll ) = $scrolled->Subwidget( 'xscrollbar', 'yscrol+lbar' );

my( $last_x, $last_y );

my $img2;

$mw->bind( '<Prior>' => \&prev_image );
$mw->bind( '<Up>'    => \&prev_image );
$mw->bind( '<Left>'  => \&prev_image );

$mw->bind( '<Next>'  => \&next_image );
$mw->bind( '<Down>'  => \&next_image );
$mw->bind( '<Right>' => \&next_image );

$imagit->bind( '<Button1-ButtonRelease>' => sub { undef $last_x } );
$imagit->bind( '<Button1-Motion>' => [ \&drag, Ev('X'), Ev('Y'), ] );

sub drag
{
    my( $w, $x, $y ) = @_;
    if ( defined $last_x )
    {
        my( $dx, $dy ) = ( $x-$last_x, $y-$last_y );
        my( $xf1, $xf2 ) = $xscroll->get;
        my( $yf1, $yf2 ) = $yscroll->get;
        my( $iw, $ih ) = ( $img2->width, $img2->height );
        if ( $dx < 0 )
        {
            $scrolled->xview( moveto => $xf1-($dx/$iw) );
        }
        else
        {
            $scrolled->xview( moveto => $xf1-($xf2*$dx/$iw) );
        }
        if ( $dy < 0 )
        {
            $scrolled->yview( moveto => $yf1-($dy/$ih) );
        }
        else
        {
            $scrolled->yview( moveto => $yf1-($yf2*$dy/$ih) );
        }
    }
    ( $last_x, $last_y ) = ( $x, $y );
}

=pod

Image scaling here is designed to strike a balance
between not wanting to scroll too much and not
wanting to lose too much resolution by downsampling.
The heuristic is:

1. if the image fits within the scrolled pane in one
or both dimensions (that is, only zero or one scrollbar
would be shown), no downsampling is done.

2. otherwise (i.e. if two scrollbars would be needed),
the downsampling factor is incremented (from 1) until
the downsampling factor is incremented (from 1) until
condition #1 (above) is met.

(Of course, we don't actually increment and check like
that; we calculate the desired factor algebraically.)

This way, when you do have to scroll, it will often be
on one axis only; and the distance you'll have to 
scroll will be minimized (or rather, optimized).

Another approach would be to downsample the picture
sufficiently such that the image always fits entirely
within the pane, and scrolling won't be necessary, but
I'd rather give minimization of resolution loss 
slightly more weight than eliminating the need to scroll.

=cut

    sub factor
    {
        my( $n, $m ) = @_;
        ($n>$m) ? int($n/$m) : 1
    }

    sub min
    {
        my( $n, $m ) = @_;
        $n < $m ? $n : $m
    }

sub show_image
{
    my $imgfile = $files[$ii];
    $mw->configure( -title => "($ii) - - - - - - -" );
    my $img1 = $mw->Photo( 'fullscale',
        -format => 'jpeg',
        -file => $imgfile,
    );
    # it's possible to manipulate an image during reading
    # from disk, but unfortunately you don't get quite as
    # much control as you do when copying one image to another,
    # and some of the things we need to do we can only do
 # during copy, not reading.
    my $factor = min(
        factor( $img1->width, $scrolled->width ),
        factor( $img1->height, $scrolled->height ),
    );
    $img2 = $mw->Photo( 'resized' );
    $img2->copy( $img1, -shrink, -subsample => $factor, $factor );
    $imagit->configure(
        -image => 'resized',
        -width => $img2->width,
        -height => $img2->height,
    );
    $mw->configure( -title => "($ii) $imgfile" );
}

sub prev_image
{
    $ii = ( $ii + @files - 1 ) % @files;
    show_image();
}

sub next_image
{
    $ii = ( $ii + 1 ) % @files;
    show_image();
}

$mw->after( 1, \&next_image );

MainLoop;