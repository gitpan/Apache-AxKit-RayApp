
package Apache::AxKit::RayApp::TeXOutput;
use strict;
use Cwd;

### use Apache::Constants qw(DONE);
use Unicode::String qw(utf8);
use Unicode::Map8;
my $l2_map = Unicode::Map8->new("latin2") or die;
my $convert = sub { $l2_map->to8(utf8($_[0])->utf16) };

sub handler {
	my $class = shift;
	my ($r, $xml, $style) = @_;

use Data::Dumper;
print STDERR Dumper $r, $xml;

	my $orig = getcwd();

	mkdir "/tmp/ray-tex-$$", 0700 or do {
		warn "\n *\nMkdir /tmp/ray-tex-$$ failed: $!\n *\n";
		return 0;
	};
	chdir "/tmp/ray-tex-$$" or do {
		warn "\n *\nChdir to /tmp/ray-tex-$$ failed: $!\n *\n";
		return 0;
	};

	my $data = $r->notes('xml_string');
	$data =~ s/^<\?.+?\?>\s*//;

	open OUT, "> /tmp/ray-tex-$$/a.tex" or do {
		warn "\n *\nWrite to /tmp/ray-tex-$$ failed: $!\n *\n";
		chdir $orig;
		return 0;
	};
	print OUT $convert->($data);
	close OUT;
	print STDERR $convert->($data);

	system("tex a.tex && dvips a.dvi");

=comment

	my $orig_translate_output = $AxKit::Cfg->{cfg}{TranslateOutput};
	$AxKit::Cfg->{cfg}{TranslateOutput} = 0;

	$r->register_cleanup( sub {
		$AxKit::Cfg->{cfg}{TranslateOutput} = $orig_translate_output;
	});

=cut

	open IN, "a.ps" or do {
		warn "\n *\Reading the Postscript failed: $!\n *\n";
		chdir $orig;
		return 0;
	};

	my $in;
	{
	local $/ = undef;
	$in = <IN>;
	}
	print STDERR "Length ", length($in), "\n";
	close IN;

	unlink 'a.tex', 'a.dvi', 'a.log', 'a.ps';
	chdir $orig;
	rmdir "/tmp/ray-tex-$$";

=comment

	system("tex a.tex");

	$AxKit::Cfg->{cfg}{TranslateOutput} = 0;

	open IN, "a.dvi" or do {
		warn "\n *\Reading the DVI failed: $!\n *\n";
		chdir $orig;
		return 0;
	};

	my $in;
	{
	local $/ = undef;
	$in = <IN>;
	}
	print STDERR "Length ", length($in), "\n";
	close IN;

	unlink 'a.tex', 'a.dvi', 'a.log', 'a.ps';
	chdir $orig;
	rmdir "/tmp/ray-tex-$$";

	system("TEXMFCNF=/packages/share/pdftex/texmf/web2c /packages/run/pdftex/bin/pdftex a.tex");

	$AxKit::Cfg->{cfg}{TranslateOutput} = 0;

	open IN, "a.pdf" or do {
		warn "\n *\Reading the PDF failed: $!\n *\n";
		chdir $orig;
		return 0;
	};

	my $in;
	{
	local $/ = undef;
	$in = <IN>;
	}
	print STDERR "Length ", length($in), "\n";
	close IN;

	unlink 'a.tex', 'a.dvi', 'a.log', 'a.ps';
	chdir $orig;
	rmdir "/tmp/ray-tex-$$";

=cut

	$r->content_type('application/postscript');
	$r->notes('ax_no_translate', 1);
	$r->notes('xml_string', $in);

	return 1;
}

sub stylesheet_exists {
	1;
}

1;

