#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::RefundRequest;
use Data::Dumper;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::RefundRequest(amount=>2.33, paymentId=>3);
print 'RefundRequest: ', Dumper($request), "\n";
my $response = $api->refund(request => $request);
print 'RefundResponse: ', Dumper($response) , "\n";


if($response->wasSuccessful())
{
	print "Successfull refund!\n";
}
else
{
	print "Refund failed..: ",$response->getMerchantErrorMessage(),"\n";
}

