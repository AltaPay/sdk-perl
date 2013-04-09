#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CaptureRequest;
use Data::Dumper;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::CaptureRequest(amount=>2.33, paymentId=>3);
print 'CaptureRequest: ', Dumper($request), "\n";
my $response = $api->capture(request => $request);
print 'CaptureResponse: ', Dumper($response) , "\n";


if($response->wasSuccessful())
{
	print "Successfull capture!\n";
}
else
{
	print "Capture failed..: ",$response->getMerchantErrorMessage(),"\n";
}

