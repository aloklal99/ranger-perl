package Ranger::Utils;
use strict;
use warnings;

use Exporter qw(import);
use Data::Dumper;

our @EXPORT_OK = qw(get_hdp_installed_version stop debug);
my $debug = 2;

# Input: an array-ref of hostnames
# Output: hdp intall version from these machines as in /usr/hdp/<version>/blah
# Throws: if version of all of the machines isn't the same!
sub get_hdp_installed_version($) {
	my ($hosts) = @_;
	my $host2version = get_hdp_install_versions($hosts);	
	print Data::Dumper->Dump([$host2version], [qw(*host2version)]);

	# build a map of version-number to count of how many times it was found in the cluster
	my %version2count = ();
	map { $version2count{$_}++ } values(%$host2version);
	print Data::Dumper->Dump([\%version2count], [qw(*version2count)]) if $debug;

	# There should be only one version intalled!
	die "Multiple versions installed in the cluster [@$hosts]"
		if grep { $_ > 1 } values %version2count;

	my @versions = keys %version2count;
	return pop @versions;
}

my %components_map = {
	'zookeeper' => 1,
	'hadoop' => 2,
	'yarn' => 3,
	'hbase' => 4,
	'hive' => 4
};

my @ordered_components = sort { $components_map{$a} <=> $components_map{$b} } keys %components_map;

# Input: an array-ref of components to stop
# Output: Subset of inputs that were successfully stopped
sub stop($) {
	my ($components) = @_;
	# We must know about all of the components
	validate_components($components);
	my %components = map { $_ => 1 } @$components;
	my @to_process = grep { defined($components{$_} } @ordered_components;
	map { stop($) } @to_process;
}

sub stop($) {
	my ($component) = @_;
	if ($component eq 'zookeeper') {
		stop_zookeeper($host);
}

# Input: array-ref: list of components validated against %component_map
# Output: throws an exception if any of the components is unknown
sub validate_components($) {
	my ($components) = @_;

	my @unknown_components = grep { !defined($components_map{$_}) } @$components;
	die "Unknown components [@unknown_components]!" if scalar(@unknown_components);
}

# Input: An array-ref of hostnames
# Returns: A map-ref of host-names to version of HDP installed in there as in /usr/hdp/<version>/blah
sub get_hdp_install_versions($) {
	my ($hosts) = @_;
	my %result = ();
	foreach my $host (@$hosts) {
		my $version = get_hdp_install_version_for_host($host);
		$result{$host} = $version;
	}
	return \%result;
}

sub get_hdp_install_version_for_host($) {
	my ($host) = @_;

	my @listing = qx(ssh $host ls /usr/hdp);
	chomp(@listing);
	print Data::Dumper->Dump([ \@listing ], [ qw(*listing) ]) if $debug;

	# filter anything that looks like, say, 2.2.0.0-2036
	my @versions = grep {
		print "grep-for-version: $_\n" if $debug == 2;
		/[\d\.-]+/
	} @listing;

	my $count = scalar @versions;
	if ($count == 0) {
		warn "No hdp install versions found in $host!  Unexpected!";
	} elsif ($count == 1) {
		return pop @versions;
	} else {
		warn "Multiple hdp install versions found in $host [@versions].  Unexpected!";
	}
}

1;
