#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::GetPaymentRequest;
use Data::Dumper;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::GetPaymentRequest(paymentId=>3);
print 'GetPaymentRequest: ', Dumper($request), "\n";
my $response = $api->getPayment(request => $request);
print 'GetPaymentResponse: ', Dumper($response) , "\n";


if($response->wasSuccessful())
{
	print "Successfully fetched the payment!\n";
}
else
{
	print "Could not fetch payment: ",$response->getMerchantErrorMessage(),"\n";
}

