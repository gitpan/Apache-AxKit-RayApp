
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

print "1..12\n";

my ($ua, $request, $response);

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => "http://localhost:$config{PORT}/rayapp/test.xml";

$response = $ua->request($request);

if ($response->is_success) {
	print "ok 1\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type ne 'text/html; charset=UTF-8') {
		print "Content type not good,\nexpected text/html; charset=UTF-8, got $content_type\nnot ";
	}
	print "ok 2\n";

	open FILE, 'data/rayapp/test.out';
	my $data = join '', <FILE>;
	close FILE;
	if ($response->content ne $data) {
		print "Content not good, expected\n[$data]\ngot\n[", $response->content, "]\nnot ";
	}
	print "ok 3\n";
} else {
	for my $i (1 .. 3) {
		print "not ok $i\n";
	}
}

eval 'use DBD::XBase';
if ($@)  {
	print "Skipping tests with database, DBD::XBase wasn't found.\n",
		map { "ok $_ # skip no XBase\n" } ( 4 .. 9 );
} else {
	$ua = new LWP::UserAgent;

	$request = new HTTP::Request GET => "http://localhost:$config{PORT}/rayapp/database/test.xml?lang=en";

	$response = $ua->request($request);

	if ($response->is_success) {
		print "ok 4\n";
		my $headers = $response->headers;
		my $content_type = $headers->header('Content-Type');
		if ($content_type ne 'text/html; charset=UTF-8') {
			print "Content type not good,\nexpected text/html; charset=UTF-8, got $content_type\nnot ";
		}
		print "ok 5\n";

		open FILE, 'data/rayapp/database/test4.out';
		my $data = join '', <FILE>;
		close FILE;
		if ($response->content ne $data) {
			print "Content not good, expected\n[$data]\ngot\n[", $response->content, "]\nnot ";
		}
		print "ok 6\n";
	} else {
		for my $i (4 .. 6) {
			print "not ok $i\n";
		}
	}

	$ua = new LWP::UserAgent;

	$request = new HTTP::Request GET => "http://localhost:$config{PORT}/rayapp/database/test.xml?user_id=522";

	$response = $ua->request($request);

	if ($response->is_success) {
		print "ok 7\n";
		my $headers = $response->headers;
		my $content_type = $headers->header('Content-Type');
		if ($content_type ne 'text/html; charset=UTF-8') {
			print "Content type not good,\nexpected text/html; charset=UTF-8, got $content_type\nnot ";
		}
		print "ok 8\n";

		open FILE, 'data/rayapp/database/test7.out';
		my $data = join '', <FILE>;
		close FILE;
		if ($response->content ne $data) {
			print "Content not good, expected\n[$data]\ngot\n[", $response->content, "]\nnot ";
		}
		print "ok 9\n";
	} else {
		for my $i (7 .. 9) {
			print "not ok $i\n";
		}
	}
}

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => "http://localhost:$config{PORT}/rayapp/localtime.xml";

$response = $ua->request($request);

if ($response->is_success) {
	print "ok 10\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type ne 'text/html; charset=UTF-8') {
		print "Content type not good,\nexpected text/html; charset=UTF-8, got $content_type\nnot ";
	}
	print "ok 11\n";

	if ($response->content eq '') {
		print "Content empty, not good\nnot ";
	}
	print "ok 12\n";
} else {
	for my $i (10 .. 12) {
		print "not ok $i\n";
	}
}
