#!/usr/bin/perl
use warnings;
use WWW::Mechanize;
use DBI;
$dbh = DBI->connect("dbi:SQLite:dbname=sh.db", "", "",
                    { RaiseError => 1, AutoCommit => 1 });
my $mech = WWW::Mechanize->new();
$mech->agent_alias( 'Windows IE 6' );
sub runtimer {
	if ($mech->content =~ /if \(i\d*<=\((\d*)\)/) { 
		print "Sleeping for $1" . "\n";
		sleep($1);
	} else { return 0; }
	if ($mech->content =~ /(WorkForm\d*)/) { 
		print "Using Form: $1\n";
		$mech->submit_form( form_name =>  $1 );
	} else { return 0; }
	return 1;
}

sub captcha {
	if ($mech->content( format => "text" ) =~ /repeat the numbers/) {
		$mech->get ("http://www.slavehack.com/workimage.php");
		$mech->save_content( "workimage.png" );
		print "Enter The Captcha\n Then Press enter followed by ctrl+d\n";
		system ("display workimage.png");
		$mech->back;
		$mech->submit_form(
		        form_number => 2,
		        fields    => {
		                            nummer  => <STDIN>
		                     },
		 );
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
	print "Logged in \n Checking For Captcha \n";
	captcha();
	if ($mech->content( format => "text" ) =~ /My computer password/) { return 1; }
	else { return 0; }
}

sub loginslave {
	my $iptologin = shift;
	print "logging to $iptologin\n";
	$mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptologin&action=login" );
	$mech->submit_form( form_number => 2 );
}
sub getslaves {
	$mech->get( 'http://www.slavehack.com/index2.php?page=slaves' );
	captcha();
	foreach ($mech->content( format => "text" ) =~ m/(\d*\.\d*\.\d*\.\d*)/g) { 
		$dbh->do("INSERT OR IGNORE INTO slaves VALUES('$_', 1, 0)") || print "already in DB";
	}
	if ($mech->content =~ /\[(\d*\.\d*\.\d*\.\d*)\]/) {
		$dbh->do("UPDATE slaves SET stat=2 WHERE ip='$1'");
	}
}

sub crackip {
	my $iptocrack = shift;
	$mech->get( "http://www.slavehack.com/index2.php?gow=$iptocrack&page=internet&action=crack" );
	captcha();
	runtimer();
}

sub clearlogs {
	my $iptoclear = shift;
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoclear&action=log" );
        captcha();
	#print $mech->form_with_fields( qw(logedit) );
        $mech->submit_form(
                form_number => 2,
                fields => {
                                logedit => '',
                                poster => 1
                                },
        );
        runtimer();
}

sub clearlocallogs {
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
	if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
		foreach ($1 =~ m/(\d*\.\d*\.\d*\.\d*)/g) {
	                $dbh->do("INSERT OR IGNORE INTO slaves VALUES('$_', 0, 0)");
		}
	}
}

sub extract_logs_bank {
        my $iptoextract = shift;
        print "Extracting logs from $iptoextract\n";
        $mech->get( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoextract&action=log" );
        captcha();
        if ($mech->content =~ /<textarea class=form name=logedit rows=35 cols=100>(.*)<\/textarea>/s) {
                foreach ($1 =~ m/(\d\d\d\d\d\d)/g) {
                        print $_ . "\n";
                }
        }
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

sub upload {
	my $iptoupl = shift;
	$mech->get ( "http://www.slavehack.com/index2.php?page=internet&gow=$iptoupl&action=files&aktie=upload" );
	captcha();
	my $uplform = $mech->form_number(2);
	my $inp = $uplform->find_input("upload");
	for ($inp->value_names) {print $_ . "\n";};
#	my @badcode = split("option", $mech->content);  # Ok, this is getting a little messy, but this is the only way I could make the regex match seperately
#	for (@badcode) { 
#		if ($_ =~ /class=form value=(\d*)>(.*)<?/) { print $1 . ":" . $2 . "\n";}
#	}
#	foreach ($mech->content =~ m/<option class=form value=(\d*)>(.*)<?/gs ) {
#		print $_ .  "\n";
#	}
}
my $login = login('ultramancool', 'hexalintbag');
#clearlocallogs();
#hunt();
loginslave("132.21.163.202");
upload("132.21.163.202");
#extract_logs_bank("135.132.154.124");
#clearlogs("134.132.154.124");
