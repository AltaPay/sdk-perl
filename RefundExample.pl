#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::RefundRequest;
use Pensio::Request::CaptureRequest;
use Pensio::Request::InitiatePaymentRequest;
use Data::Dumper;
use Test::More tests => 3;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::InitiatePaymentRequest(
	amount=>2.33, 
	orderId=>"refund_"+Pensio::Examples::getRandomOrderId(),
	terminal=>'Pensio Test Terminal',
	currency=>'EUR',
	cardnum=>'4111000011110000',
	emonth=>'03',
	eyear=>'2042',
);

my $initiateResponse = $api->initiatePayment(request => $request);

ok ($initiateResponse->wasSuccessful(), "Successfull initiate!")
	or diag("Initiate before capture failed..: ",Dumper($initiateResponse));

my $paymentId = $initiateResponse->getPrimaryPayment()->getId();

my $request = new Pensio::Request::CaptureRequest(
	amount=>2.33, 
	paymentId=>$paymentId
);

my $response = $api->capture(request => $request);

ok ($response->wasSuccessful(), "Successfull capture!")
	or diag("Capture failed..: ",Dumper($response));




my $request = new Pensio::Request::RefundRequest(
	amount=>2.33, 
	paymentId=>$paymentId,
	reconciliationIdentifier=>"my local id"
);

my $response = $api->refund(request => $request);


ok ($response->wasSuccessful(), "Successfull refund!")
	or diag("Refund failed..: ",Dumper($response));
