
package Apache::AxKit::RayApp::DumpXML;
use strict;

sub handler {
	my $class = shift;
	my ($r, $xml_provider, $style_provider) = @_;
	### print STDERR "$r, $xml_provider, $style_provider\n";

	my $log = Apache->request->log();

	if ($r->pnotes('dom_tree')) {
		$log->info("[RayApp::DumpXML] : Printing out XML string from dom_tree.\n"
			. $r->pnotes('dom_tree')->toString);
		return 0;
	}
	elsif ($r->notes('xml_string')) {
		$log->info("[RayApp::DumpXML] : Printing out XML string from xml_string via notes:\n"
			. $r->notes('xml_string'));
		return 0;
	}
	elsif ($r->pnotes('xml_string')) {
		$log->info("[RayApp::DumpXML] : Printing out XML string from xml_string:\n"
			. $r->pnotes('xml_string'));
		return 0;
	}
	else {
		my $data = $xml_provider->get_strref;
		$log->info("[RayApp::DumpXML] : Printing out XML string from xml_provider:\n$$data");
		return 0;
	}
	$log->warn("[RayApp::DumpXML] : Unreachable code.");
	return 0;
}

sub stylesheet_exists {
	1;
}

1;

