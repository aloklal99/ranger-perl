use strict;
use warnings;
use Data::Dumper;

my $debug = 0;

my %files = ();
sub parse_line($) {
	my ($line) = shift;

	my ($action, $stats) = ($line =~ /^.*\[(.):.*?\](.*)/);
	return ( $action, $stats );
}

sub is_stats_line($) {
	my ($line) = shift;

	return 1 if ($line =~ /util.MultiThreadedAction/);
}

sub record_results($$) {
	my ($file_name, $stats) = @_;
	$files{$file_name} = $stats;
}

sub parse_stats($) {
	my $stats = shift;

	my ($keys, $cols, $time, $overall) = ($stats =~ /Keys=(\d+).*cols=([^,]*).*time=([^ ]*).*Overall: \[(.*?)\]/);
	printf "|%s|%s|%s|%s|\n", $keys, $cols, $time, $overall if $debug;
	my ($keysPerSec, $latency) = ($overall =~ /keys\/s=\s*(\d+).*latency=\s*(\d+)\s*ms/);
	printf "|%s|%s|\n", $keysPerSec, $latency if $debug;

	return {
		keys => $keys,
		cols => $cols,
		time => $time,
		'keys/s' => $keysPerSec,
		latency => $latency,
	}
}

sub parse_file_name($) {
	my ($file) = shift;
	return ( $1, $2 ) if ($file =~ /hbase.run.log.(\d+)\.(\d+)/)
}

sub compare_file_names($$) {
	my ($a, $b) = @_;
	my ($a_run, $a_iter) = parse_file_name($a);
	my ($b_run, $b_iter) = parse_file_name($b);
	return $a_run == $b_run ? $a_iter <=> $b_iter : $a_run <=> $b_run;
}

sub print_line(@) {
	print join("\t", @_), "\n";
}

sub print_header() {
	my @columns = qw(run iteration type keys keys/s time latency-ms cols);
	print_line(@columns);
}

sub tabulate_data($) {
	my ($map) = shift;

	print_header();

	foreach my $file (sort { compare_file_names($a, $b) } keys %$map) {
		my ($run, $iter) = parse_file_name($file);
		foreach my $type (keys $map->{$file}) {
			my $keys = $map->{$file}{$type}{keys};
			my $keysPerSec = $map->{$file}{$type}{'keys/s'};
			my $time = $map->{$file}{$type}{time};
			my $latency = $map->{$file}{$type}{latency};
			my $cols = $map->{$file}{$type}{cols};
			print_line($run, $iter, $type, $keys, $keysPerSec, $time, $latency, $cols);
		}
	}
}

sub main {
	my %raw = ();

	while (<>) {
		# first time around filename would be null;
		if (is_stats_line($_)) {
			my ($action, $stats) = parse_line($_);
			printf "%s|%s|\n", $action, $stats if $debug;
			# store data with current file-name
			$raw{$ARGV}{$action} = $stats;
		}
	}

	print Dumper(\%raw) if $debug;
	my %stats = ();

	foreach my $file (keys %raw) {
		printf "|%s|\n", $file if $debug;
		foreach my $action (keys $raw{$file}) {
			printf "|%s|%s|%s|\n", $file, $action, $raw{$file}{$action} if $debug;
			$stats{$file}{$action} = parse_stats($raw{$file}{$action});
		}
	}

	print Dumper(\%stats) if $debug;

	tabulate_data(\%stats);
}

sub test {
	my @result = parse_file_name('hbase.run.log.2.3');
	print "@result\n";
	my ($b, $a) = ('hbase.run.log.2.3', 'hbase.run.log.2.3');
	my $p = compare_file_names($a, $b);
	print "p = $p\n";

	print_header();
	print_line(q(a b c));
}

main();
# test();
