
my $out_file = shift;

my %config;
open CONFIG, 'test-config';
while (<CONFIG>) {
	chomp;
	my ($key, $val) = split /=/, $_, 2;
	$config{$key} = $val if defined $key;
}
close CONFIG;

open OUT, "> $out_file";
while (<DATA>) {
	s/\@(ROOT_DIRECTORY|USER|HTTPD|GROUP|PORT)\@/$config{$1}/g;
	print OUT;
}
close OUT;

__DATA__

ServerType standalone
Port @PORT@
Listen @PORT@

User @USER@
Group @GROUP@

ServerRoot @ROOT_DIRECTORY@

ErrorLog log/error_log
LogLevel debug
LogFormat "%h %l %u %t \"%r\" %>s %b %T" common

CustomLog log/access_log common

PidFile log/httpd.pid

ScoreBoardFile log/httpd.scoreboard

Timeout 5

MinSpareServers 1
MaxSpareServers 2

StartServers 2

MaxClients 5

MaxRequestsPerChild 30

DocumentRoot @ROOT_DIRECTORY@/data

PerlModule AxKit
AxNoCache On

<Directory @ROOT_DIRECTORY@/data/axkit-libxml/>
AxNoCache On
AxAddStyleMap text/xsl Apache::AxKit::Language::LibXSLT

Options FollowSymLinks ExecCGI MultiViews Indexes
SetHandler perl-script
PerlHandler AxKit
</Directory>

<Directory @ROOT_DIRECTORY@/data/axkit-sablotron/>
AxNoCache On
AxAddStyleMap text/xsl Apache::AxKit::Language::Sablot

Options FollowSymLinks ExecCGI MultiViews Indexes
SetHandler perl-script
PerlHandler AxKit
</Directory>

<Directory @ROOT_DIRECTORY@/data/axkit88591/>
AxNoCache On
### AxCacheDir /nocache
AxAddStyleMap text/xsl Apache::AxKit::Language::Sablot
AxTranslateOutput On
AxOutputCharset iso-8859-1
### AxDebugLevel 9

Options FollowSymLinks ExecCGI MultiViews Indexes
SetHandler perl-script
PerlHandler AxKit
</Directory>

<Location /rayapp/>
AxNoCache On
### AxCacheDir /nocache
AxAddStyleMap text/xsl Apache::AxKit::Language::LibXSLT
AxAddStyleMap application/x-ray-run Apache::AxKit::RayApp::RunCode
AxAddStyleMap application/x-ray-dump Apache::AxKit::RayApp::DumpXML
AxAddStyleMap application/x-xpathscript Apache::AxKit::Language::XPathScript
### AxTranslateOutput On
### AxOutputCharset ISO-8859-2
### AxDebugLevel 9
### PerlSetVar AxRayDebugLevel 0
### PerlSetVar AxRayDumpXML 6
PerlSetVar AxRayReturnXML show_xml
AxConfigReader Apache::AxKit::RayApp

Options FollowSymLinks ExecCGI MultiViews Indexes
SetHandler perl-script
PerlHandler AxKit

</Location>

<Location /rayapp/database/>
AxNoCache On
AxAddStyleMap text/xsl Apache::AxKit::Language::LibXSLT
AxAddStyleMap application/x-ray-run Apache::AxKit::RayApp::RunCode
AxAddStyleMap application/x-ray-dump Apache::AxKit::RayApp::DumpXML
AxAddStyleMap application/x-xpathscript Apache::AxKit::Language::XPathScript
### AxDebugLevel 9
### PerlSetVar AxRayDebugLevel 6
PerlSetVar AxRayDbhConnect Apache::AxKit::RayApp::Test::XBase
PerlSetVar AxRayAppCharset ISO-8859-2
PerlSetVar AxRayParamPropagate lang,myuco
AxConfigReader Apache::AxKit::RayApp
Options FollowSymLinks ExecCGI MultiViews Indexes
SetHandler perl-script
PerlHandler AxKit
</Location>

ExtendedStatus On

<Location /server/status>
SetHandler server-status
</Location>

<Location /server/info>
SetHandler server-info
</Location>

