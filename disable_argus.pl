use strict;
use warnings;
use POSIX;
use Data::Dumper;
use File::Compare;

# invoke the script with -n.  It expects on machine name per line
sub get_file($$$) {
	my ($host, $dir, $file) = @_;
	my $tmp = tmpnam();
	system ("scp $host:$dir/$file $tmp");
	die "scp failed: $!\n" if $?;
	return $tmp;
}

sub get_hbase_config($) {
	my ($host) = shift;
	my ($dir, $file) = ('/etc/hbase/conf', 'hbase-site.xml');
	return get_file($host, $dir, $file);
}

sub compare_files(@) {
	my @files = @_;
	my $a = pop @files;
	return grep { compare($a, $_) != 0 } @files;
}

my %hosts = ();
foreach my $host (@ARGV) {
	$hosts{$host} = get_hbase_config($host);
}
print Dumper(\%hosts);

my @different = compare_files(values %hosts);

