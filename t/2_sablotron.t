
eval 'use XML::Sablotron;';
if ($@) {
        print "Module XML::Sablotron couldn't be loaded, won't test.\n1..0\n";
        exit;
}

print "1..6\n";

my %config;
open CONFIG, 'test-config';
while (<CONFIG>) {
        chomp;
        my ($key, $val) = split /=/, $_, 2;
        $config{$key} = $val if defined $key;
}
close CONFIG;

if (not defined $config{ROOT_DIRECTORY}) {
	print 'not ';
}
print "ok 1\n";

my $parser = new XML::Sablotron() or print 'not ';

print "ok 2\n";

$parser->process(new XML::Sablotron::Situation,
	"file://$config{ROOT_DIRECTORY}/data/axkit-sablotron/axkit.xslt",
	"file://$config{ROOT_DIRECTORY}/data/axkit-sablotron/axkit.xml",
	'arg:result') and print 'not ';

print "ok 3\n";

my $result;
$result = $parser->getResultArg('arg:result') or print 'not ';

print "ok 4\n";

open EXPECTED, 'data/axkit-sablotron/axkit.out' or print 'not ';

print "ok 5\n";

my $expected = join '', <EXPECTED>;
chomp $expected;

close EXPECTED;

if ($result ne $expected) {
	print "Got:\n[$result]\nexpected:\n[$expected]\nnot ";
}

print "ok 6\n";

