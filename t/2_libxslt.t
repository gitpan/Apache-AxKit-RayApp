
eval 'use XML::LibXSLT; use XML::LibXML;';
if ($@) {
	print "Modules XML::LibXSLT and XML::LibXML couldn't be loaded, won't test.\n1..0\n";
	exit;
}

print "1..8\n";

my $parser = XML::LibXML->new() or print 'not ';

print "ok 1\n";

my $xslt = XML::LibXSLT->new() or print 'not ';

print "ok 2\n";

my $source = $parser->parse_file('data/axkit-libxslt/axkit.xml') or print 'not ';

print "ok 3\n";

my $style_doc = $parser->parse_file('data/axkit-libxslt/axkit.xslt') or print 'not ';

print "ok 4\n";

my $stylesheet = $xslt->parse_stylesheet($style_doc) or print 'not ';

print "ok 5\n";

my $results = $stylesheet->transform($source) or print 'not ';

print "ok 6\n";

open EXPECTED, 'data/axkit-libxslt/axkit.out' or print 'not ';

print "ok 7\n";

my $expected = join '', <EXPECTED>;

close EXPECTED;

if ($stylesheet->output_string($results) ne $expected) {
	print "Got:\n[", $stylesheet->output_string($results),
		"]\nexpected:\n[$expected]\nnot ";
}

print "ok 8\n";

