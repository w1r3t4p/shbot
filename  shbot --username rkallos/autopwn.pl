use warnings;
use IO::Socket::INET;
my $client;
my $attackip = shift;
$client = IO::Socket::INET->new("localhost:9988");
runcmd("LOGIN ... ...") . "\n";

my $timer = runcmd("CRACKIP $attackip\n");
if ($timer =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1;}

print runcmd("LOGINSLAVE $attackip\n"). "OK";

my $time2 = runcmd("CLEAR_LOGS_IP\n");
if ($time2 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1;}
<$client>; # feed a line as it prints extra crap

my $newtimer = runcmd("UPLOAD $attackip 1647003\n");
if ($newtimer =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }
<$client>; # feed a line, upload prints return and timer.

sleep(2); #wait 2 seconds for no apparent reason.
my $viridfinder = runcmd("VIR_INST_LIST $attackip\n") . "\n" ;
#print "RUN WHAT VIRID:\n"; my $virid = <STDIN>;
my $virid;
if ($viridfinder =~ /RETURN  (\d*)/) { $virid = $1; }

my $time3 = runcmd("VIR_INST $attackip $virid\n");
if ($time3 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }

$time2 = runcmd("CLEAR_LOGS_IP\n");
if ($time2 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }

sub runcmd {
my $command = shift;
print "Execing: $command\n";
print $client $command;
return <$client> . "\n";
}
