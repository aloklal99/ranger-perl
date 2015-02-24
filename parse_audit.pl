use strict;
use warnings;
use JSON;
use Data::Dumper;

sub compare_arrays($$) {
	my ($a, $b) = @_;
	my %map = ();
	$map{$_}++ for @{$a};
	return grep { !exists($map{$_}) } @{$b};
}

sub main() {
	my @keys = ();
	my $i = 0;
	while (<>) {
		$i++;
		chomp;
		my $hash = decode_json($_);
		# print Dumper($hash);
		my @new_keyset = keys(%$hash);
		if (@keys) {
			if (compare_arrays(\@keys, \@new_keyset)) {
				print "@new_keyset\n";
			}
		}
		else {
			@keys = @new_keyset;
			print "@keys\n";
		}
		print "$i\n" if ($i % 100000) == 0;
	}
}

main();
