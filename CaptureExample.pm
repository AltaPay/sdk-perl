#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::CaptureRequest;
use Data::Dumper;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $response = $api->capture(new Pensio::CaptureRequest(amount=>2.33, paymentId=>3));
print 'CaptureResponse: ', Dumper($response) , "\n";


if($response->wasSuccessful())
{
	print "Successfull capture!\n";
}
else
{
	print "Capture failed..: ",$response->getMerchantErrorMessage(),"\n";
}

