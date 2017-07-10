#!/usr/bin/perl
#
# Klarna test script.
#
#
package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CaptureRequest;
use Data::Dumper;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

# CAPTURE: =============================================================================

my $paymentId = '156'; # PUT A PAYMENT ID FROM A PREVIOUSLY CREATED ORDER HERE
	
my $request = new Pensio::Request::CaptureRequest(paymentId=>$paymentId);
	
my $response = $api->capture(request => $request);
	
if (!$response->wasSuccessful()) {
	print("Capture was declined: " . $response->getMerchantErrorMessage());
}
		
