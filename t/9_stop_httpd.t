#!/usr/bin/perl -w

if (not -f 'log/httpd.pid') {
	print "Test httpd didn't run.\n1..0\n";
	exit;
}

print "1..1\n";

open PID, 'log/httpd.pid';
my $PID = <PID>;
close PID;
chmod $PID;

kill 15, $PID;

unlink 'log/httpd.pid';

print "ok 1\n";

