#!/usr/bin/perl -w

print "1..1\n";

eval 'use Apache::AxKit::RayApp;';
if ($@) {
	print "The Apache::AxKit::RayApp couldn't be reasonable loaded:\n$@\nnot ";
}

print "ok 1\n";

