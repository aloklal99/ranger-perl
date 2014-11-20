#!/usr/bin/env perl -w

use strict;
use warnings;
use Data::Dumper;

use Ranger::Utils qw(get_hdp_installed_version);

my $debug = 1;

my $hosts = [ '172.18.145.95' ];
my $hdp_version = get_hdp_installed_version($hosts);

print Data::Dumper->Dump([ $hdp_version ], [ qw(hdp_version) ]) if $debug;

