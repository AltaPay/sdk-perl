#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::Verify3DSecureRequest;
use Data::Dumper;


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


if($response->wasSuccessful())
{
	print "Successfull CreditCard payment!\n";
}
else
{
	print "Payment failed..: ",$response->getMerchantErrorMessage(),"\n";
}

# Now with 3D-Secure (okay)
$request->cardnum('4170000000000568');
$request->terminal('Pensio Test 3DSecure Terminal');
print 'InitiatePaymentRequest: ', Dumper($request), "\n";
$response = $api->initiatePayment(request => $request);
print 'InitiatePaymentResponse: ', Dumper($response) , "\n";


if($response->was3DSecure())
{
	print "3D-Secure CreditCard payment: ", $response->getRedirectUrl(), ", PaReq:", $response->getPaReq(), "\n";
	my $verifyRequest = new Pensio::Request::Verify3DSecureRequest(
		paymentId => $response->getPrimaryPayment()->getId(),
		paRes => 'WorkingPaRes', # This is a hack, you would normally get this posted back after sending the browser to the redirect URL
	);
	print 'Verify3DSecureRequest: ', Dumper($verifyRequest), "\n";
	my $verifyResponse = $api->verify3DSecure(request => $verifyRequest);
	print 'Verify3DSecureResponse: ', Dumper($verifyResponse) , "\n";

	if($verifyResponse->wasSuccessful())
	{
		print "Successfull 3D-Secure CreditCard payment!\n";
	}
	else
	{
		print "3D-Secure Validation failed..: ",$verifyResponse->getMerchantErrorMessage(),"\n";
	}
}
else
{
	print "Non-3D-Secure Payment\n";
}

