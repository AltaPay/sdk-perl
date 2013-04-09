#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CreatePaymentRequestRequest;
use Data::Dumper;
use Test::More tests => 1;


my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::CreatePaymentRequestRequest(
	amount=>2.33, 
	orderId=>'testOrder',
	terminal=>'Pensio Test Terminal',
	currency=>'EUR',
	
);

my $response = $api->createPaymentRequest(request => $request);

ok ($response->wasSuccessful(), "Created payment request succesfully!")
	or diag("Created payment request failed..: ",Dumper($response));
	
note($response->getUrl());
