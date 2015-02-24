use strict;
use warnings;

my %types = ( 1 => 'No argus', 2 => 'No audit', 3 => 'HDFS only' );
my $num_keys = 100_000, # hundred thousand keys

sub start($) {
	my $host = shift;
	my $result = qx(ssh $host "/tmp/stop_all.bash 2>&1");
	return $result;
}

sub stop {
	my $host = shift;
	my $result = qx(ssh $host "/tmp/stop_all.bash");
	return $result;
}

sub no_argus {
}

sub run_test {
	ssh $host "hbase org.apache.hadoop.hbase.util.LoadTestTool -start_key 0 -num_keys $num_keys -bloom ROWCOL -compression NONE -write 10:100:100 -read 100:20 -tn loadtest_d1 > /tmp/run.log.hdfs 2>&1"
}
