
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

### print "1..6\n";
print "1..3\n";

my ($ua, $request, $response);

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => "http://localhost:$config{PORT}/axkit-sablotron/axkit.xml";

$response = $ua->request($request);

if ($response->is_success) {
	print "ok 1\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type ne 'text/xml; charset=UTF-8') {
		print "Content type not good,\nexpected text/xml; charset=UTF-8, got $content_type\nnot ";
	}
	print "ok 2\n";

	open FILE, 'data/axkit-sablotron/axkit.out';
	my $data = join '', <FILE>;
	chomp $data;
	close FILE;
	if ($response->content ne $data) {
		print "Content not good, expected\n[$data]\ngot\n[", $response->content, "]\nnot";
	}
	print "ok 3\n";
} else {
	for my $i (1 .. 3) {
		print "not ok $i\n";
	}
}

=comment

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => 'http://localhost:8023/axkit88591/axkit.xml';

$response = $ua->request($request);

if ($response->is_success) {
	print "ok 4\n";
	my $headers = $response->headers;
	my $content_type = $headers->header('Content-Type');
	if ($content_type ne 'text/xml; charset=ISO-8859-1') {
		print "Content type not good,\nexpected text/xml; charset=ISO-8859-1, got $content_type\nnot ";
	}
	print "ok 5\n";

	open FILE, 'data/axkit88591/axkit.out';
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

=cut

__END__

$ua = new LWP::UserAgent;

$request = new HTTP::Request GET => 'http://localhost:8023/page.xml';

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

