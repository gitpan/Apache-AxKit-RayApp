
use ExtUtils::MakeMaker;
use Cwd;

# Let's check if there is a bug in Apache::AxKit::Provider::File
eval 'use Apache::AxKit::Provider::File';
if ($@) {
	print STDERR <<'EOF';

	The AxKit package really has to be installed bacause RayApp
	only extends its capabilities.

EOF
} else {
	# OK, so some Apache::AxKit::Provider::File is available
	print STDERR <<'EOF';

	Please make sure that Apache::AxKit::Provider::File is patched to work
	properly for file:// URIs, the patch is in Provider-File.pm.patch.

EOF
}

my %config;
if (open CONFIG, 'test-config') {
	while (<CONFIG>) {
		chomp;
		my ($key, $val) = split /=/, $_, 2;
		$config{$key} = $val if defined $key;
	}
	close CONFIG;
}

my $reconfigure = 0;
if (@ARGV and $ARGV[0] eq '-r') {
	shift @ARGV;
	$reconfigure = 1;
}

for (@ARGV) {
	chomp;
	my ($key, $val) = split /=/, $_, 2;
	$config{$key} = $val if defined $key;
}

$config{ROOT_DIRECTORY} = getcwd;
print "Using source directory [$config{ROOT_DIRECTORY}]\n";

if ($reconfigure or not defined $config{HTTPD}) {
	$config{HTTPD} = prompt "Where is your mod_perl enabled Apache?",
								$config{HTTPD};
	if (not -f $config{HTTPD} and -x $config{HTTPD}) {
		print STDERR "We probably won't be able to run the tests, the file doesn't exist.\n";
		sleep 3;
	}
	$config{PORT} = 8023 if not defined $config{PORT};
	$config{PORT} = prompt "On what port should the test Apache run?",
								$config{PORT};

	if (not defined $config{USER}) {
		$config{USER} = getpwuid($>);
		$config{USER} = 'nobody' if $config{USER} eq 'root';
	}
	$config{USER} = prompt "Under what UID should we run the test Apache?",
								$config{USER};

	if (not defined $config{GROUP}) {
		$config{GROUP} = $);
		$config{GROUP} =~ s/ .*//;
		$config{GROUP} = getgrgid($config{GROUP});
		$config{GROUP} = 'nobody' if $config{GROUP} eq 'root';
	}
	$config{GROUP} = prompt "Under what GID should we run the test Apache?",
								$config{GROUP};
} else {
	print <<"EOF";
We will run tests with the following values:
Apache:	[$config{HTTPD}]
Port:	[$config{PORT}]		User:	[$config{USER}]		Group:	[$config{GROUP}]
To update these values, run `perl Makefile.PL -r'.
EOF
}

if (open CONFIG, '> test-config') {
	for (keys %config) {
		print CONFIG "$_=$config{$_}\n";
	}
	close CONFIG;
}

sub MY::processPL {
	package MY;	# so that "SUPER" works right
	my $inherited = shift->SUPER::processPL(@_);
	$inherited =~ s/^(\w.+\.PL)/$1 test-config/mg;
	return $inherited;
}

WriteMakefile(
	'NAME'		=> 'Apache::AxKit::RayApp',
	'VERSION_FROM'	=> 'lib/Apache/AxKit/RayApp.pm',
	'dist'		=> { COMPRESS => 'gzip -9f',
				SUFFIX => '.gz',
				POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../'
		},
	'PREREQ_PM'	=> { 'AxKit' => 1.3,
				'Unicode::String' => 0,
				'Unicode::Map8' => 0,
				'XML::LibXSLT' => 0,
		},
	'PL_FILES'	=> {
				'conf/httpd.conf.PL' => 'conf/httpd.conf',
		},
	);

