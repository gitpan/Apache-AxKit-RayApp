
package Apache::AxKit::RayApp::RunCode;

use strict;
use vars qw/@ISA/;
use Apache::AxKit::Language::XPathScript;
use Apache::AxKit::Provider::File;
use Apache::Request;

@ISA = 'Apache::AxKit::Language::XPathScript';

sub handler {
	my $class = shift;
	my ($r, $xml_provider, $style_provider, $reparse) = @_;

	### print STDERR "Started RayApp::RunCode::handler($class, $r, $xml_provider, $style_provider, $reparse)\n";

	$r->no_cache(1);

	my $fh = $style_provider->get_fh;
	my $key = $style_provider->key;

	my $package = $key;
	$package =~ s/([^A-Za-z0-9_\/])/sprintf("_%2x",unpack("C",$1))/eg;
	$package =~ s!(/+)(\d?)! "::" . (length $2 ? sprintf("_%2x",unpack("C",$2)) : "") !ge;
	$package = 'Apache::ROOT' . $package;

	if ($AxKit::Cfg->RayAppDebugLevel() > 2) {
                my $log = Apache->request->log();
                $log->info("[RayApp] : RunCode: Got fh $fh, key $key");
                $log->info("[RayApp] : RunCode: Package $package");
        }

	my $content = join '', <$fh>;

	eval "package $package; $content";
	if ($@) {
                my $log = Apache->request->log();
                $log->warn("[RayApp] : RunCode: Perl code invalid:\n$@");
		return 1;
	}
	### print STDERR "Content $content\n";

	my $sub = \&{"$package\::handler"};
	my $result;

	my $q = Apache::Request->new($r);

	my @params = ($r, $q);

	if (defined(my $dbh_module = $r->dir_config('AxRayDbhConnect'))) {
		eval "use $dbh_module";
		if ($@) {
			my $log = Apache->request->log();
			$log->error("[RayApp] : RunCode: Error loading module $dbh_module:\n$@");
			return 1;
		}
		my $dbh = eval "$dbh_module->connect;";
		if (not defined $dbh) {
			my $log = Apache->request->log();
			$log->error("[RayApp] : RunCode: Error connecting to database via $dbh_module:\n$DBI::errstr\n");
			return 1;
		}
		push @params, $dbh;
		if ($AxKit::Cfg->RayAppDebugLevel() > 2) {
			my $log = Apache->request->log();
			$log->warn("[RayApp] : RunCode: Connected to database via $dbh_module");
		}
	}

	eval { $result = &{$sub}(@params) };
	if ($@) {
                my $log = Apache->request->log();
                $log->warn("[RayApp] : RunCode: Perl code run failed:\n$@");
		return 1;
	}
	if ($AxKit::Cfg->RayAppDebugLevel() > 2) {
                my $log = Apache->request->log();
                $log->warn("[RayApp] : RunCode: Perl code run OK");
        }

	$r->pnotes('rayapp_result', $result);

	my $PACKAGE = __PACKAGE__;
	$PACKAGE =~ s!::!/!g;
	my $XPS_DIRECTORY = $INC{$PACKAGE . '.pm'};
	$XPS_DIRECTORY =~ s!/[^/]*$!!;

	$style_provider->{'file'} = "$XPS_DIRECTORY/FitDataToXML.xps";
	if ($AxKit::Cfg->RayAppDebugLevel() > 2) {
                my $log = Apache->request->log();
                $log->warn("[RayApp] : Calling XPathScript::handler [$style_provider->{'file'}]");
        }

	return Apache::AxKit::Language::XPathScript->handler($r,
			$xml_provider, $style_provider, $reparse);
}

1;

