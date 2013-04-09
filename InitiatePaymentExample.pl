#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::Verify3DSecureRequest;
use Data::Dumper;
use Test::More tests => 3;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::InitiatePaymentRequest(
	amount=>2.33, 
	orderId=>'testOrder',
	terminal=>'Pensio Test Terminal',
	currency=>'EUR',
	cardnum=>'4111000011110000',
	emonth=>'03',
	eyear=>'2042',
);
print 'InitiatePaymentRequest: ', Dumper($request), "\n";
my $response = $api->initiatePayment(request => $request);
print 'InitiatePaymentResponse: ', Dumper($response) , "\n";


ok ($response->wasSuccessful(), "Successfull CreditCard payment!")
	or diag("Payment failed..: ",$response->getMerchantErrorMessage());

# Now with 3D-Secure (okay)
$request->cardnum('4170000000000568');
$request->terminal('Pensio Test 3DSecure Terminal');

note('InitiatePaymentRequest: ', Dumper($request));

$response = $api->initiatePayment(request => $request);

note('InitiatePaymentResponse: ', Dumper($response));

if($response->was3DSecure())
{
	pass("Created 3D Secure payment successfully");
	note("3D-Secure CreditCard payment: ", $response->getRedirectUrl(), ", PaReq:", $response->getPaReq());
	my $verifyRequest = new Pensio::Request::Verify3DSecureRequest(
		paymentId => $response->getPrimaryPayment()->getId(),
		paRes => 'WorkingPaRes', # This is a hack, you would normally get this posted back after sending the browser to the redirect URL
	);
	note('Verify3DSecureRequest: ', Dumper($verifyRequest));
	
	my $verifyResponse = $api->verify3DSecure(request => $verifyRequest);
	
	note('Verify3DSecureResponse: ', Dumper($verifyResponse));

	ok ($verifyResponse->wasSuccessful(), "Successfull 3D-Secure CreditCard payment!")
		or diag("3D-Secure Validation failed..: ",Dumper($verifyResponse))
}
else
{
	fail("Did not create 3D Secure payment successfully");
}

