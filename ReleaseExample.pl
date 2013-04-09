#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::ReleaseRequest;
use Data::Dumper;
use Test::More tests => 2;

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
my $initiateResponse = $api->initiatePayment(request => $request);

ok ($initiateResponse->wasSuccessful(), "Successfull initiate!")
	or diag("Initiate before capture failed..: ",Dumper($initiateResponse));
my $paymentId = $initiateResponse->getPrimaryPayment()->getId();
my $request = new Pensio::Request::ReleaseRequest(paymentId=>$paymentId);
note('CaptureRequest: ', Dumper($request));
my $response = $api->release(request => $request);
note('CaptureResponse: ', Dumper($response));

ok ($response->wasSuccessful(), "Successfull release!")
	or diag("Release failed..: ",Dumper($response));
	
