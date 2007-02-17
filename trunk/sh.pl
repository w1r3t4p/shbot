#!/usr/bin/perl
package shbot;

use base qw(Net::Server);
use warnings;
use WWW::Mechanize;
use DBI;
$dbh = DBI->connect("dbi:SQLite:dbname=sh.db", "", "",
                    { RaiseError => 1, AutoCommit => 1 });
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows IE 6' );
sub runtimer {
	if ($mech->content =~ /if \(i\d*<=\((\d*)\)/) { 
		print "TIMER $1" . "\n";
		sleep($1);
	} else { return 0; }
	if ($mech->content =~ /(WorkForm\d*)/) { 
		$mech->submit_form( form_name =>  $1 );
	} else { return 0; }
	return 1;
}

sub crep {
	my $captret = shift;
                $mech->submit_form(
                        form_number => 2,
                        fields    => {
                                            nummer  => $captret
                                     },
                 );
}


sub captcha {
	if ($mech->content( format => "text" ) =~ /repeat the numbers/) {
		$mech->get ("http://www.slavehack.com/workimage.php");
		print "CAPTCHA" .  # $mech->content; removed for testing, since client is _not_ working yet.
		$mech->save_content ("workimage.png");
 		system ("display workimage.png");
		$mech->back;
	}
}

sub login {
	$mech->get ( "http://www.slavehack.com/index.php" );
	$mech->submit_form(
	    form_number => 1,
	    fields    => { 
				login  => shift, 
				loginpas => shift
	                 },
	);
	captcha();
	if ($mech->content( format => "text" ) =~ /My computer password/) { return 1; }
	else { return 0; }
}

sub loginslave {
	my $iptologin = shift;
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptologin&action=login" );
	$mech->submit_form( form_number => 2 );
}
sub getslaves {
	$mech->get( 'http://www.slavehack.com/index2.php?page=slaves' );
	captcha();
	my $toret;
	foreach ($mech->content( format => "text" ) =~ m/(\d*\.\d*\.\d*\.\d*)/g) { 
		$toret = $toret . " " . $_;
	}
	return $toret;
}

sub crackip {
	my $iptocrack = shift;
	$mech->get( "http://www.slavehack.com/index2.php?gow=$iptocrack&page=internet&action=crack" );
	captcha();
	runtimer();
}

sub clear_logs {
	my $iptoclear = shift;
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoclear&action=log" );
        captcha();
        $mech->submit_form(
                form_number => 2,
                fields => {
                                logedit => '',
                                poster => 1
                                },
        );
        runtimer();
}

sub clear_local_logs {
	$mech->get( 'http://www.slavehack.com/index2.php?page=logs' );
	captcha();
	$mech->submit_form(
		form_number => 1,
		fields => {
				logedit => '',
				poster => 1
				},
	);
	runtimer();
}

sub extract_logs {
	my $iptoextract = shift;
	print "Extracting logs from $iptoextract\n";
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoextract&action=log" );
	captcha();
	my $toret;
	if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
		foreach ($1 =~ m/(\d*\.\d*\.\d*\.\d*)/g) {
			$toret = $toret . " " . $_;
		}
	}
	return $toret;
}

sub extract_logs_bank {
        my $iptoextract = shift;
        print "Extracting logs from $iptoextract\n";
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoextract&action=log" );
        captcha();
	my $toret;
        if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
                foreach ($1 =~ m/(\d\d\d\d\d\d)/g) {
                        $toret = $toret . " " . $_;
                }
        }
	return $toret;
}

sub hunt {
	getslaves();
	my $all = $dbh->selectall_arrayref("SELECT ip FROM slaves WHERE stat=1");
	foreach my $row (@$all) {
		my $ip = @$row;
		print $ip . "SLAVE";
		loginslave($ip);
		extract_logs($ip);
	        my $run = $dbh->selectall_arrayref("SELECT ip FROM slaves WHERE stat=0");
	        foreach my $row2 (@$run) {
        	        my $ip2 = @$row2;
			print $ip2 . "noob";
			crackip($ip2);
	                loginslave($ip2);
	                extract_logs($ip2);
	        }
	}
}

sub upl_list {
	my $iptoupl = shift;
	$mech->get ( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoupl&action=files&aktie=upload" );
	captcha();
	my $uplform = $mech->form_number(2);
	my $inp = $uplform->find_input("upload");
	my @sw = $inp->value_names;
	my @ids = $inp->possible_values;
	my $iter = 0;
	foreach (@ids) { print $ids[$iter] . ":" . $sw[$iter] . " "; $iter++; }
}

sub process_request {
     my $self = shift;
     while (<STDIN>) {
     	chomp;
	my @command = split(/ /, $_);
	if ($command[0] eq "LOGIN") { print "RETURN " . login($command[1], $command[2]); }
	elsif ($command[0] eq "CAPRET") { crep($command[1]); }
	elsif ($command[0] eq "GETSLAVES") { print "RETURN " . getslaves(); } 
	elsif ($command[0] eq "LOGINSLAVE") { loginslave($command[1]); print "RETURN 1"; } #Note to add error detection!!!
	elsif ($command[0] eq "CRACKIP") { crackip($command[1]); print "RETURN 1"; } #Note to add error detection!!!
        elsif ($command[0] eq "EXTRACT_LOGS") { print "RETURN " . extract_logs($command[1]); }
	elsif ($command[0] eq "EXTRACT_LOGS_BANK") { print "RETURN " . extract_logs_bank($command[1]); }
	elsif ($command[0] eq "CLEAR_LOGS") { clear_logs($command[1]); print "RETURN 1";}
	elsif ($command[0] eq "CLEAR_LOCAL_LOGS") { clear_local_logs(); print "RETURN 1"; }
	elsif ($command[0] eq "UPL_LIST") { return upl_list($command[1]);}
	else { print "RETURN 0" } 
        last if /QUIT/i; # Drop connection on QUIT
     }
}
shbot->run(port => 9988);
