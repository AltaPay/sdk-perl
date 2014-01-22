#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::ReleaseRequest;
use Data::Dumper;
use Test::More tests => 3;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

sub initiatePayment {
	my ($cardnum) = @_;
	
	if(not defined $cardnum) {
		$cardnum = '4111000011110000';
	}
	
	my $request = new Pensio::Request::InitiatePaymentRequest(
		amount=>2.33, 
		orderId=>"release_".Pensio::Examples::getRandomOrderId(),
		terminal=>$terminal,
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

	
subtest 'Release success test' => sub {
	
	my $paymentId = initiatePayment();
		
	my $response = $api->release(request => new Pensio::Request::ReleaseRequest(paymentId=>$paymentId));
	
	ok ($response->wasSuccessful(), "Successfull release!")
		or diag("Release failed..: ",Dumper($response));
};

subtest 'Release declined test' => sub {
	
	my $paymentId = initiatePayment('4111000011110866');
		
	my $response = $api->release(request => new Pensio::Request::ReleaseRequest(paymentId=>$paymentId));
	
	ok (!$response->wasSuccessful(), "Declined release!")
		or diag("Release was not declined..: ",Dumper($response));
};

subtest 'Release error test' => sub {
	
	my $paymentId = initiatePayment('4111000011110867');
		
	my $response = $api->release(request => new Pensio::Request::ReleaseRequest(paymentId=>$paymentId));
	
	ok (!$response->wasSuccessful(), "Errored release!")
		or diag("Release was not errored..: ",Dumper($response));
};