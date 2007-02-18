use warnings;
use IO::Socket::INET;
my $client;
my $attackip = shift;
$client = IO::Socket::INET->new("localhost:9988");
print runcmd("LOGIN ultramancool hexalintbag\n") . "\n";
print "Logged in\n";
my $timer = runcmd("CRACKIP $attackip\n");
if ($timer =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }
print runcmd("LOGINSLAVE $attackip\n"). "OK";
my $time2 = runcmd("CLEAR_LOGS_IP\n");
if ($time2 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }
my $uselessline = <$client> . "\n";
my $newtimer = runcmd("UPLOAD $attackip 1646390\n");
print "|" . $newtimer;
print "|";
if ($newtimer =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }
#my $uselessline = <$client> . "\n";

print runcmd("VIR_INST_LIST $attackip\n") . "\n" ;
print "RUN WHAT VIRID:\n"; my $virid = <STDIN>;
my $time3 = runcmd("VIR_INST $attackip $virid\n");
#if ($time3 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }

my $time2 = runcmd("CLEAR_LOGS_IP\n");
if ($time2 =~ /TIMER (\d*)/) { print $1 . "\n"; sleep $1; print "a\n" }

sub runcmd {
my $command = shift;
print $client $command;
return <$client> . "\n";
}
