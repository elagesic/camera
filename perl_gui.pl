#1. Install padre perl in host computer
#2. install tk module
#C:\Users\palaskar\Downloads\Tk-804.034\Tk-804.034
#Go to Downloads where  module is downloaded in its tar version
#Extract it
#cd C:\Users\palaskar\Downloads\Tk-804.034\Tk-804.034
#perl Makefile.PL
#dmake
#dmake test
#dmake install
#Once the module is installed, go sample scripts or examples from command window and run those test scripts using "perl script_nmae:
#If those tests run successfully, place your new scripts along with those scripts and go ahead.
#3. Update device ids and their IPs 
#4. convert program to executable
#cpan -i PAR::Packer
#pp -o example example.pl


use Tk;
use Tk::JPEG;
use Tk::Pane;
use IO::Socket::INET;

my @IP_Address;
$IP_Address[0] = '192.168.1.7';	#IP input from user
$IP_Address[1] = '192.168.1.3';   	#IP input from user
$IP_Address[2] = '192.168.1.4';   	#IP input from user
$IP_Address[3] = '192.168.1.6';   	#IP input from user
$IP_Address[4] = '192.168.1.5';   	#IP input from user
my $trig =0;
my $num_Rpi;


#Global Variables
my $dir = shift || '.';
chdir $dir or die "Can't go do $dir - $!\n";
$filespec = "*.jpg";
@files = glob $filespec ;

my $ii = -1; # image index

#my $dw ;

my $gender = "Hide";
my $data;
my $scrolled;
my $imagit;

# Main Window
my $mw = new MainWindow;

my $value = 0;

#imag navigation
$mw->bind( '<Prior>' => \&prev_image );
$mw->bind( '<Up>'    => \&prev_image );
$mw->bind( '<Left>'  => \&prev_image );

$mw->bind( '<Next>'  => \&next_image );
$mw->bind( '<Down>'  => \&next_image );
$mw->bind( '<Right>' => \&next_image );

#$imagit->bind( '<Button1-ButtonRelease>' => sub { undef $last_x } );
#$imagit->bind( '<Button1-Motion>' => [ \&drag, Ev('X'), Ev('Y'), ] );


#GUI Building Area
my $frm_name = $mw -> Frame();
$frm_name -> grid(-row=>1,-column=>1,-columnspan=>2);

my $frm_but = $mw -> Frame();
$frm_but -> grid(-row=>2,-column=>1,-columnspan=>2);

my @lab, @ent, @frm_name;

#create 120 camera entries
foreach my $i (1..30) 
{
$lab[$i] = $frm_name -> Label(-text=>"Camera_$i:");
$ent[$i] = $frm_name -> Entry(-width => 15, );
$lab[$i] -> grid(-row=>$i,-column=>1);
$ent[$i] -> grid(-row=>$i,-column=>2);      
}

foreach my $i (31..60) 
{
$lab[$i] = $frm_name -> Label(-text=>"Camera_$i:");
$ent[$i] = $frm_name -> Entry(-width => 15, );
$lab[$i] -> grid(-row=>$i-30,-column=>3);
$ent[$i] -> grid(-row=>$i-30,-column=>4);      
}

foreach my $i (61..90) 
{
$lab[$i] = $frm_name -> Label(-text=>"Camera_$i:");
$ent[$i] = $frm_name -> Entry(-width => 15, );
$lab[$i] -> grid(-row=>$i-60,-column=>5);
$ent[$i] -> grid(-row=>$i-60,-column=>6);      
}

foreach my $i (91..120) 
{
$lab[$i] = $frm_name -> Label(-text=>"Camera_$i:");
$ent[$i] = $frm_name -> Entry(-width => 15, );
$lab[$i] -> grid(-row=>$i-90,-column=>7);
$ent[$i] -> grid(-row=>$i-90,-column=>8);      
}

# Buttons for various camera functions
$frm_but->Button(-text => "Clear", -command =>\&Clear)->grid
  ($frm_but->Button(-text => "Load", -command =>\&Load),
   $frm_but->Button(-text => "Trigger", -command =>\&Trigger),
   $frm_but->Button(-text => "Display", -command =>\&Display),
   -sticky => "nsew", -padx => 10, -pady => 10, -ipadx => 10, -ipady => 10);

                                              
#Show or hide string
my $frm_gender = $mw -> Frame();
my $lbl_gender = $frm_gender -> Label(-text=>"String");
my $rdb_m = $frm_gender -> Radiobutton(-text=>"Hide",  
        -value=>"Hide",  -variable=>\$gender);
my $rdb_f = $frm_gender -> Radiobutton(-text=>"Show",
        -value=>"Show",-variable=>\$gender);


#Text Area
my $textarea = $mw -> Frame();
my $txt = $textarea -> Text(-width=>100, -height=>3);
my $srl_y = $textarea -> Scrollbar(-orient=>'v',-command=>[yview => $t
+xt]);
my $srl_x = $textarea -> Scrollbar(-orient=>'h',-command=>[xview => $t
+xt]);
$txt -> configure(-yscrollcommand=>['set', $srl_y],
        -xscrollcommand=>['set',$srl_x]);

#Geometry Management
$lbl_gender -> grid(-row=>1,-column=>1);
$rdb_m -> grid(-row=>1,-column=>2);
$rdb_f -> grid(-row=>1,-column=>3);
$frm_gender -> grid(-row=>3,-column=>1,-columnspan=>2);
$txt -> grid(-row=>1,-column=>1);
$srl_y -> grid(-row=>1,-column=>2,-sticky=>"ns");
$srl_x -> grid(-row=>2,-column=>1,-sticky=>"ew");
$textarea -> grid(-row=>5,-column=>1,-columnspan=>2);

MainLoop;

## Functions
#This function will be executed when the button is pushed
sub Clear 
{

foreach my $i (1..30) 
{
$ent[$i] = $frm_name -> Entry(-width => 15, -textvariable => $value);
$ent[$i] -> grid(-row=>$i,-column=>2);      
}

foreach my $i (31..60) 
{
$ent[$i] = $frm_name -> Entry(-width => 15, -textvariable => $value);
$ent[$i] -> grid(-row=>$i-30,-column=>4);      
}

foreach my $i (61..90) 
{
$ent[$i] = $frm_name -> Entry(-width => 15, -textvariable => $value);
$ent[$i] -> grid(-row=>$i-60,-column=>6);      
}

foreach my $i (91..120) 
{
$ent[$i] = $frm_name -> Entry(-width => 15, -textvariable => $value);
$ent[$i] -> grid(-row=>$i-90,-column=>8);      
}

$txt -> delete('1.0','end');

}

sub Load 
{

my $string;
my $star = "a";
 
# Create Delay String 
foreach my $i (1..120) 
{
my $name = $ent[$i] -> get();
$string = $string . $name;
$string = $string . $star;

if ($i eq 120)
{
$num_Rpi = $name;
print "Rpi connected is $num_Rpi \n";
}

}

if ($gender eq "Show")
{
$txt -> insert('end',"$string");
}  
   
$data = $string;	#Delay input string from user
my $folder = 'folder1';		#Newfolder input from user: newfolder button or input name for new folder

# Start UDP socket for delay string transmission
my $socket;
$socket = new IO::Socket::INET(
	PeerPort => 1234,
	PeerAddr => '192.168.1.255',
	Proto => 'udp'
) or die "error in socket creation";



if($socket->send($data))
{
print "Delay Loaded\n";
}

$socket->close();
}

sub Trigger 
{
	
my $folder = "folder.$trig";		#Newfolder input from user
chdir 'C:\Users\palaskar\Desktop' ; 
#$dir = $folder;
# Start UDP socket for Trigger Command transmission
my $socket;
$socket = new IO::Socket::INET(
	PeerPort => 1234,
	PeerAddr => '192.168.1.255',
	Proto => 'udp'
) or die "error in socket creation";

if($socket->send("R"))
{
print "Camera Triggered\n";
}

system("TIMEOUT 8");
# Create folder in local directory
system("mkdir $folder");
my $cnt = 'C:\Users\palaskar\Desktop"';
# Download images from Raspberries
my $temp;
foreach my $IP (@IP_Address)
{
system("pscp.exe -pw raspberry pi\@$IP:\/home\/pi\/Perl_tests\/udp_receive\/I* $folder/");
#system("pscp.exe -pw raspberry pi\@$IP:\/home\/pi\/Perl_tests\/udp_receive\/C* $folder/");

$temp = $temp +1;
if ($temp eq $num_Rpi)
{
break;
}
}
$socket->close();

$dir = "$folder/";
#print "previous is $previous\n";
chdir $dir or die "Can't go do $dir - $!\n";

#print "after is $after\n";
$filespec = "*.jpg";
@files = glob $filespec;


#chdir $cnt or die "Can't go do $cnt - $!\n";
$trig = $trig+1;
}



sub Display 
{
#$dw = MainWindow->new(-title=>"Demo");
$dw = MainWindow->new(-title=>"Demo");
$flag = 1;

$scrolled = $dw
    ->Scrolled( 'Pane', -scrollbars => 'osoe', -width => 5184, -height => 3456, )
    ->pack( -expand => 1, -fill => 'both', );

$imagit = $scrolled
    ->Label
    ->pack( -expand => 1, -fill => 'both', );

my( $xscroll, $yscroll ) = $scrolled->Subwidget( 'xscrollbar', 'yscrol+lbar' );

my( $last_x, $last_y );

my $img2;

$dw->after( 1, \&next_image );

MainLoop;



}

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
    $dw->configure( -title => "($ii) - - - - - - -" );
    my $img1 = $dw->Photo( 'fullscale',
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

    $img2 = $dw->Photo( 'resized' );
    $img2->copy( $img1, -shrink, -subsample => 3, 3 );
    $imagit->configure(
        -image => 'resized',
        -width => $img2->width,
        -height => $img2->height,
    );
    $dw->configure( -title => "($ii) $imgfile" );
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
