
eval 'use LWP::UserAgent;';
if ($@) {
	print "Couldn't find LWP::UserAgent, cannot run tests.\n1..0\n";
	exit;
}

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

if (not -f 'log/httpd.pid') {
	print "Test httpd didn't run.\n1..0\n";
	exit;
}

print "1..6\n";

my $ua = new LWP::UserAgent;

my $request = new HTTP::Request GET => "http://localhost:$config{PORT}/page.html";

my $response = $ua->request($request);

if ($response->is_success) {
	print "ok 1\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type eq 'text/html') {
		print "ok 2\n";
	} else {
		print "Content type not good, expected text/html, got $content_type\n";
		print "not ok 2\n";
	}
	open FILE, 'data/page.html';
	my $data = join '', <FILE>;
	close FILE;
	if ($response->content eq $data) {
		print "ok 3\n";
	} else {
		print "not ok 3\n";
	}
} else {
	for my $i (1 .. 3) {
		print "not ok $i\n";
	}
}

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => "http://localhost:$config{PORT}/page.xml";

$response = $ua->request($request);

if ($response->is_success) {
	print "ok 4\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type eq 'text/xml') {
		print "ok 5\n";
	} else {
		print "Content type not good, expected text/html, got $content_type\n";
		print "not ok 5\n";
	}
	open FILE, 'data/page.xml';
	my $data = join '', <FILE>;
	close FILE;
	if ($response->content eq $data) {
		print "ok 6\n";
	} else {
		print "not ok 6\n";
	}
} else {
	for my $i (4 .. 6) {
		print "not ok $i\n";
	}
}

