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


sub initiatePayment {
	my ($cardnum, $amount) = @_;
	
	if(not defined $amount) {
		$amount = 2.33;
	}
	
	if(not defined $cardnum) {
		$cardnum = '4111000011110000';
	}

	my $request = new Pensio::Request::InitiatePaymentRequest(
		amount=>$amount, 
		orderId=>"refund_".Pensio::Examples::getRandomOrderId(),
		terminal=>'Pensio Test Terminal',
		currency=>'EUR',
		cardnum=>$cardnum,
		emonth=>'03',
		eyear=>'2042',
	);
	
	my $initiateResponse = $api->initiatePayment(request => $request);
	
	ok ($initiateResponse->wasSuccessful(), "Successfull initiate!")
		or diag("Initiate before capture failed..: ",Dumper($initiateResponse));
		
	return $initiateResponse->getPrimaryPayment()->getId();
}

sub capture {
	my ($paymentId, $amount) = @_;
	
	if(not defined $amount) {
		$amount = 2.33;
	}
	
	my $request = new Pensio::Request::CaptureRequest(
		amount=>2.33, 
		paymentId=>$paymentId
	);
	
	my $response = $api->capture(request => $request);
	
	ok ($response->wasSuccessful(), "Successfull capture!")
		or diag("Capture failed..: ",Dumper($response));
}

sub refund {

	my ($paymentId, $amount) = @_;
	
	if(not defined $amount) {
		$amount = 2.33;
	}

	my $request = new Pensio::Request::RefundRequest(
		amount=>2.33, 
		paymentId=>$paymentId,
		reconciliationIdentifier=>"my local id"
	);
	
	my $response = $api->refund(request => $request);
	
	
	return $response;
}

subtest 'Refund test' => sub {

	my $paymentId = initiatePayment();
	
	capture($paymentId);
	
	my $response = refund($paymentId);
	
	ok ($response->wasSuccessful(), "Successfull refund!")
		or diag("Refund failed..: ",Dumper($response));
};

subtest 'Refund failing test' => sub {

	my $paymentId = initiatePayment('4111000011110966');
	
	capture($paymentId);
	
	my $response = refund($paymentId);
	
	ok (!$response->wasSuccessful(), "Failing refund!")
		or diag("Refund did not fail..: ",Dumper($response));
	
	is ($response->getMerchantErrorMessage(), "TestAcquirer[transaction.amount=9.66 case][10966]", "Correct error message");
};

subtest 'Refund error test' => sub {

	my $paymentId = initiatePayment('4111000011110967');
	
	capture($paymentId);
	
	my $response = refund($paymentId);
	
	ok (!$response->wasSuccessful(), "Failing refund!")
		or diag("Refund did not fail..: ".Dumper($response));
		
	is ($response->getMerchantErrorMessage(), "TestAcquirer[capture_amount=9.67 case]", "Correct error message");
		
};