use strict;
use warnings;

use REST::Client;
use MIME::Base64;

my $host = "172.18.145.229";
my $repo = "hadoopdev";
my $client = REST::Client->new();
my $debug = 1;

sub getUrl($$) {
	my ($host, $repo) = @_;
	my $url_format = "http://%s:6080/service/public/api/policy?respositoryName=%s";
	return sprintf $url_format, $host, $repo;
}

sub getAuth() {
	my ($user, $password) = ('admin', 'admin');
	return sprintf("Basic %s", encode_base64("$user:$password"));
}

sub getPolicy($) {
	my ($url, $resource) = @_;
	$client->setHost("$url&resourceName=$resource");
	$client->addHeader("Authentication", getAuth());
}
	
my $url = getUrl($host, $repo);
print "url = $url\n" if $debug;

