#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::CaptureRequest;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $response = $api->capture(Pensio::CaptureRequest->new(amount=>10, paymentId=>1));

if($response->wasSuccessful())
{
	print "Successfull login!\n";
}
else
{
	print "Login failed...\n";
}

