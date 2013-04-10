#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::CaptureRequest;
use Data::Dumper;
use Test::More tests => 4;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());


sub initiatePayment {
	my ($cardnum) = @_;
	
	if(not defined $cardnum) {
		$cardnum = '4111000011110000';
	}

	my $request = new Pensio::Request::InitiatePaymentRequest(
		amount=>2.33, 
		orderId=>"capture_".Pensio::Examples::getRandomOrderId(),
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
};

subtest 'Capture success test' => sub {
	
	my $paymentId = initiatePayment();
	
	my $request = new Pensio::Request::CaptureRequest(amount=>2.33, paymentId=>$paymentId);
	
	my $response = $api->capture(request => $request);
	
	ok ($response->wasSuccessful(), "Successfull capture!")
		or diag("Capture failed..: ",Dumper($response));

};	


subtest 'Capture declined test' => sub {
	
	my $paymentId = initiatePayment("4111000011110766");
	
	my $request = new Pensio::Request::CaptureRequest(amount=>2.33, paymentId=>$paymentId);
	
	my $response = $api->capture(request => $request);
	
	ok (!$response->wasSuccessful(), "Declined capture!")
		or diag("Capture was not declined: ",Dumper($response));
};	

subtest 'Capture error test' => sub {
	
	my $paymentId = initiatePayment("4111000011110767");
	
	my $request = new Pensio::Request::CaptureRequest(amount=>2.33, paymentId=>$paymentId);
	
	my $response = $api->capture(request => $request);
	
	ok (!$response->wasSuccessful(), "Errored capture!")
		or diag("Capture was not errored: ",Dumper($response));
};
	
subtest 'Capture success with loads of data test' => sub {
	
	my $paymentId = initiatePayment();
	
	my $request = new Pensio::Request::CaptureRequest(
		amount=>2.33, 
		paymentId=>$paymentId,
		reconciliationIdentifier=>"my local id",
		invoiceNumber=>"my invoice number",
		salesTax=>12.3
	);
	
	$request->orderLines()->add(
		description => "Product 1",
		itemId => "Product id 1",
		quantity => 1.24,
		taxPercent => 20.0,
		unitCode => "kg",
		unitPrice => 123.42,
		discount => 0.42,
		goodsType => "item"
	);
	
	$request->orderLines()->add(
		description => "Product 2",
		itemId => "Product id 2",
		quantity => 4,
		taxPercent => 25.0,
		unitCode => "",
		unitPrice => 15423.42,
		discount => 52.54,
		goodsType => "item"
	);
	
	my $response = $api->capture(request => $request);
	
	ok ($response->wasSuccessful(), "Successfull capture with all options enabled!")
		or diag("Capture failed..: ",Dumper($response));
};
	