#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Data::Dumper;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $response = $api->login();
print 'LoginResponse: ', Dumper($response) , "\n";

if($response->wasSuccessful())
{
	print "Successfull login!\n";
}
else
{
	print "Login failed...\n";
}

