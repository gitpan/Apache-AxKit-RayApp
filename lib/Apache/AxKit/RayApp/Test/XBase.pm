
package Apache::AxKit::RayApp::Test::XBase;

use DBI;

sub connect {
	my $r = Apache->request;
	my $document_root = $r->document_root;
	### print STDERR "\n\tRunnig Apache::AxKit::RayApp::Test::XBase::connect.\n\t\@INC=[@INC]\n"; 

	return DBI->connect("dbi:XBase:$document_root",
		undef, undef, { PrintError => 1 });
}

1;

