
=head1 NAME

Apache::AxKit::RayApp - Framework for logic and presentation separation

=cut

package Apache::AxKit::RayApp;

use strict;
use Apache::AxKit::ConfigReader;
use vars qw! @ISA $VERBOSE $VERSION !;
@ISA = qw! Apache::AxKit::ConfigReader !;

$VERSION = '0.44';
$VERBOSE = 1;

### warn "RayApp loading\n";

sub PreferredMedia {
	my $self = shift;
	my $r = $self->{'apache'};
	my %in = $r->args();
	if ($in{media}) {
		$r->notes('rayapp_media', $in{media});
	} else {
		$r->notes('rayapp_media', 'screen');
	}
	return $r->notes('rayapp_media');
}

sub OutputCharset {
	my $self = shift;
	if ($self->{apache}->notes('ax_no_translate') == 1) {
		return;
	}
	return $self->SUPER::OutputCharset(@_);
}

sub RayAppDebugLevel {
	my $self = shift;
	my $level = $self->{apache}->dir_config('AxRayDebugLevel');
	if (defined $level) { return $level; }
	return $self->DebugLevel;
}

sub RayAppDumpXMLLevel {
	my $self = shift;
	my $level = $self->{apache}->dir_config('AxRayDumpXML');
	if (defined $level) {
		if ($level > 0) {
			return 9;
		} else {
			return 0;
		}
	}
	return $self->RayAppDebugLevel();
}

sub GetMatchingProcessors {
	my $self = shift;

	### warn "\n\n### RayApp::GetMatchingProcessors\n";

###	$self->{'cfg'}->AxAddStyleMap(undef, 'application/x-ray-run',
###				'Apache::AxKit::RayApp::RunCode');
###	$self->{'cfg'}->AxAddStyleMap(undef, 'application/x-ray-dump',
###				'Apache::AxKit::RayApp::DumpXML');
###	$self->{'cfg'}->AxAddStyleMap(undef, 'application/x-ray-structure',
###				'Apache::AxKit::Language::Sablot');
###	$self->{'cfg'}->AxAddStyleMap(undef, 'application/x-ray-texdvi',
###				'Apache::AxKit::RayApp::TeXOutput');

	my ($media, $style, $doctype, $dtd, $root, $styles) = @_;

	# filename of the XML file, with the base structure
	my $filename = $self->{'apache'}->filename;

	my @results = ();

	# if the input XML specified some structure expandor(s), we
	# will honor them
	if (defined $styles) {
		push @results, grep { $_->{'type'} eq 'application/x-ray-structure' } @$styles;
	}
	# by default we will not do any structure expansion

	if (@results and $AxKit::Cfg->RayAppDumpXMLLevel() > 3) {
		push @results, {
			'alternate' => 'no',
			'media' => 'all',
			'type' => 'application/x-ray-dump',
			'module' => 'Apache::AxKit::RayApp::DumpXML'
			};
	}

	# now add the script with the code
	my $was_script = 0;
	if (defined $styles) {
		push @results, map { $was_script = 1; $_ }
			grep { $_->{'type'} eq 'application/x-ray-run' } @$styles;
	}

	# no script name specified in the XML file, check for
	# reasonable defaults
	if (not $was_script) {
		(my $scriptname = $filename) =~ s/\.[^.]+?$/.plx/;
		if (not -f $scriptname) {
			$scriptname =~ s/\.plx$/.pl/;
		}
		### $scriptname =~ s!^.*/!!;
		push @results,
			{
			'alternate' => 'no',
			'media' => 'all',
			'type' => 'application/x-ray-run',
			'href' => "file://$scriptname",
			'module' => 'Apache::AxKit::RayApp::RunCode'
			};
	}

	# dump the output of the script

	if ($AxKit::Cfg->RayAppDumpXMLLevel() > 3) {
		push @results, {
			'alternate' => 'no',
			'media' => 'all',
			'type' => 'application/x-ray-dump',
			'module' => 'Apache::AxKit::RayApp::DumpXML'
			};
	}

	my $show_only_xml = $self->{apache}->dir_config('AxRayReturnXMLParam');
	if (defined $show_only_xml) {
		my %in = $self->{'apache'}->args();
		if ($in{$show_only_xml} eq '1') {
			return @results;
		}
	}

	# and now the presentation stage
	my $was_presentation = 0;
	if (defined $styles) {
		push @results, map { $was_presentation = 1; $_ }
			grep { $_->{'type'} !~ m!^application/x-ray-.+! } @$styles;
	}

	if (not $was_presentation) {
		push @results,
			{
			'alternate' => 'no',
			'media' => 'all',
			'type' => 'text/xsl',
			'uri' => 'file:///www/xml/ray/DATA/default.xslt',
			'module' => 'Apache::AxKit::Language::Sablot'
			};
	}

	my $PACKAGE = __PACKAGE__;
	$PACKAGE =~ s!::!/!g;
	my $XPS_DIRECTORY = $INC{$PACKAGE . '.pm'};
	$XPS_DIRECTORY =~ s!/[^/]*$!!;
	$XPS_DIRECTORY .= '/RayApp';

	if ($AxKit::Cfg->RayAppDebugLevel() > 2) {
		my $log = Apache->request->log();
		$log->warn("[RayApp] : XPS_DIRECTORY: $XPS_DIRECTORY");
	}

	if ($media eq 'screen') {
		if ($AxKit::Cfg->RayAppDumpXMLLevel() > 3) {
			push @results,
				{
				'alternate' => 'no',
				'media' => 'all',
				'type' => 'application/x-ray-dump',
				'module' => 'Apache::AxKit::RayApp::DumpXML'
				};
		}
		push @results, {
			'alternate' => 'no',
			'media' => 'screen',
			'type' => 'application/x-xpathscript',
			'href' => "file://$XPS_DIRECTORY/FinalLinkHTMLRun.xps",
			'module' => 'Apache::AxKit::Language::XPathScript'
			};
	} elsif ($media eq 'print') {
		push @results, {
			'alternate' => 'no',
			'media' => 'print',
			'type' => 'application/x-ray-texdvi',
			'module' => 'Apache::AxKit::RayApp::TeXOutput'
			};
	}

    return @results;
}

1;


=head1 SYNOPSIS

	SetHandler perl-script
	AxConfigReader Apache::AxKit::RayApp
	PerlHandler AxKit

=head1 DESCRIPTION

Under B<RayApp>, the structure of application data is described in
application.xml XML file, the application code is in application.plx
Perl source code, and the resulting XML file with the data from the
code execution is processed by XML transformation, preferrably by XSLT
formatting.

The structure XML file has to describe the desired XML file that should
be the result of the application run. The XML file has to include two
special elements, C<data> and C<datalist> with attribute C<name>.
These will be filled in by the data returned from the application
Perl code.

The application Perl code has to be one or more functions. One of them
has to be named C<handler>. The handler function is passed two
parameters, Apache (the C<$r>) and Apache::Request (the C<$q>). The
function should return a hash of values, which will be interpolated
into the structure XML description.

The structure description file shall have one xml-stylesheet processing
instruction which will be applied after the application code is run
and the resulting data is interpolated to the XML stream.

=head1 CONFIGURATION in httpd.conf

You can control the behaviour of B<RayApp> by following
configuration directives:

=over 4

=item AxRayDebugLevel

	PerlSetVar AxRayDebugLevel 7

Specifies the debug level for B<RayApp> code. It overrides the
AxDebugLevel value, if specified. If not specified, AxDebugLevel is
used.

=item AxRayDumpXML

	PerlSetVar AxRayDumpXML 1

If set to 1, the XML data that is produced and passed among B<RayApp>
processing stages is printed to error_log. If not specified, the value
of AxRayDebugLevel (or AxDebugLevel) is used, so setting AxRayDebugLevel
to true gives you dumps of the data as well. You can switch this off
explicitely by setting AxRayDumpXML to zero.

Only a true/false (1/0) value range is recognized.

=item AxRayDbhConnect

	PerlSetVar AxRayDbhConnect Project::DBI::Source

If this value is specified, B<RayApp> will use that module and call
connect method on it, in the example above it would be

	$dbh = Project::DBI::Source->connect;

This DBI database handler is then passed as the third parameter to
Perl application, to that handler subroutine.

=item AxRayAppCharset

	PerlSetVar AxRayDbhConnect ISO-8859-2

The application code may want to process and return data in other
charset than the standard used internally by XML parsers, UTF-8.
You can specify the character set either in the configuration file, or
in the returned data as value of '!charset'.

=item AxRayParamPropagate

	PerlSetVar AxRayParamPropagate lang,su

Comma separated list of parameters that will be automatically added
to every HTML link on the output page.

=item AxRayReturnXML

	PerlSetVar AxRayReturnXMLParam show_data

Name of parameter which will make B<RayApp> to stop processing after
the application data was fitted into the XML. In the query string,
you need to give this parameter value 1, like

	/application.xml?show_data=1

=back

=head1 VERSION

0.43

=head1 AUTHOR

(c) 2000--2001 Jan Pazdziora, adelton@fi.muni.cz,
http://www.fi.muni.cz/~adelton/ at Masaryk University, Brno,
Czech Republic.

=cut

