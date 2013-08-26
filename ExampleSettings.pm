package Pensio::Examples;

use strict;

our $installation_url = 'http://cigateway.mars.pensio.com';
our $terminal         = 'Pensio Soap Test Terminal';
our $username         = 'shop api'; 
our $password         = 'testpassword'; 
our $shared_secret    = 'testsecret';

sub getRandomOrderId {
	my @chars = ("A".."Z", "a".."z");
	my $string;
	$string .= $chars[rand @chars] for 1..8;
	
	return $string;
}
