#!/usr/bin/env perl -w

use strict;
use warnings;

use Data::Dumper;
use Getopt::Long;

use Ranger::Utils qw(get_hdp_installed_version);

my $debug = 1;
my @hosts = ();
my @components = ();

sub show_usage() {
	print <<EOF
usage: <script-name> --host <host1> --host <host2> --host <host3>
	where host1, host2, etc. are hostnames of your cluster
EOF
}

GetOptions(
	"host=s" => \@hosts,
	"component=s" => \@components
) or die "Couldn't parse command line!\n";

# assert we have the right input
die "At least one host must be specified!\n" . show_usage()
	unless scalar(@hosts);
die "At least one component must be specified!\n" . show_usage()
	unless scalar(@components);

my $hdp_version = get_hdp_installed_version(\@hosts);
print Data::Dumper->Dump([ $hdp_version ], [ qw(hdp_version) ]) if $debug;

stop({ 
	components => 
	hosts => $hosts,
	version => $hdp_version
});


