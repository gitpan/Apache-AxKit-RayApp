
my %config;
open CONFIG, 'test-config';
while (<CONFIG>) {
        chomp;
        my ($key, $val) = split /=/, $_, 2;
        $config{$key} = $val if defined $key;
}
close CONFIG;

if (not defined $config{ROOT_DIRECTORY}) {
	print "Configuration couldn't be read.\n1..0\n";
	exit;
}

print "1..2\n";

print "ok 1\n";

mkdir 'log', 0755;
unlink 'log/httpd.pid';

use ExtUtils::testlib;

$ENV{'PERL5LIB'} = join ':', map { "$config{ROOT_DIRECTORY}/$_" } grep /^[^\/]/, @INC;
print "Starting $config{HTTPD} -f $config{ROOT_DIRECTORY}/conf/httpd.conf\nwith PERL5LIB set to $ENV{'PERL5LIB'}\n";
my $out = `$config{HTTPD} -f $config{ROOT_DIRECTORY}/conf/httpd.conf 2>&1 &`;

my $PID;
my $seconds = 1;
sleep $seconds;
for (0 .. 4) {
	if ($out ne '') {
		last;
	}
	if (open PID, 'log/httpd.pid') {
		$PID = <PID>;
		close PID;
		chomp $PID;
		sleep 1;
		last;
	}
	$seconds++;
	sleep $seconds;
}

if (not defined $PID) {
	warn "\nCouldn't start httpd, please check log/error_log.\n$out\n";
	print "not ok 2\n";
	exit;
}

print "Good, we have httpd (pid $PID).\n";
print "ok 2\n";

