#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::Verify3DSecureRequest;
use Data::Dumper;
use Test::More tests => 4;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

sub initiatePayment {
	my ($cardnum, $terminal) = @_;
	
	if(not defined $cardnum) {
		$cardnum = '4111000011110000';
	}
	
	if(not defined $terminal) {
		$terminal = 'Pensio Test Terminal';
	}

	my $request = new Pensio::Request::InitiatePaymentRequest(
		amount=>2.33, 
		orderId=>"capture_".Pensio::Examples::getRandomOrderId(),
		terminal=>$terminal,
		currency=>'EUR',
		cardnum=>$cardnum,
		emonth=>'03',
		eyear=>'2042',
	);
	
	my $initiateResponse = $api->initiatePayment(request => $request);
	
	
		
	return $initiateResponse;
};

subtest 'Initiate regular payment test' => sub {
	my $initiateResponse = initiatePayment();
	
	ok ($initiateResponse->wasSuccessful(), "Successfull initiate!")
		or diag("Initiate failed..: ",Dumper($initiateResponse));
};

subtest 'Initiate regular declined payment test' => sub {
	my $initiateResponse = initiatePayment('4170000000000566');
	
	ok (!$initiateResponse->wasSuccessful(), "Declined initiate!")
		or diag("Initiate was not declined..: ",Dumper($initiateResponse));
};

subtest 'Initiate regular errored payment test' => sub {
	my $initiateResponse = initiatePayment('4170000000000567');
	
	ok (!$initiateResponse->wasSuccessful(), "Errored initiate!")
		or diag("Initiate was not errored..: ",Dumper($initiateResponse));
};

subtest 'Initiate 3d secure payment test' => sub {
	
	$response = initiatePayment('4170000000000568', 'Pensio Test 3DSecure Terminal');
	
	if($response->was3DSecure())
	{
		pass("Created 3D Secure payment successfully");
		
		note("3D-Secure CreditCard payment: ", $response->getRedirectUrl(), ", PaReq:", $response->getPaReq());
		
		my $verifyRequest = new Pensio::Request::Verify3DSecureRequest(
			paymentId => $response->getPrimaryPayment()->getId(),
			paRes => 'WorkingPaRes', # This is a hack, you would normally get this posted back after sending the browser to the redirect URL
		);
		
		my $verifyResponse = $api->verify3DSecure(request => $verifyRequest);
		
	
		ok ($verifyResponse->wasSuccessful(), "Successfull 3D-Secure CreditCard payment!")
			or diag("3D-Secure Validation failed..: ",Dumper($verifyResponse))
	}
	else
	{
		fail("Did not create 3D Secure payment successfully");
	}
};
