#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CreateInvoiceReservationRequest;
use Pensio::Request::CustomerInfo;
use Pensio::Request::OrderLines;
use Data::Dumper;
use Test::More tests => 2;

my $api = new Pensio::PensioAPI( $installation_url, $username, $password );
$api->setLogger( new ExampleStdoutLogger() );

sub createRequest {

	my ($ci) = @_;

	my $request = new Pensio::Request::CreateInvoiceReservationRequest(
		terminal     => 'AltaPay Test Invoice Terminal DK',
		orderId      => 'CreateInvoiceReservationTest_' . Pensio::Examples::getRandomOrderId(),
		amount       => 12.42,
		currency     => 'DKK',
		customerInfo => $ci
	);

	return $request;
}

subtest 'Test simple invoice reservation request' => sub {

	my $ci = new Pensio::Request::CustomerInfo();

	$ci->email('myuser@mymail.com');
	$ci->billingAddress()->address('bill address');
	$ci->billingAddress()->postalCode('1111');

	my $request = createRequest($ci);

	my $response = $api->createInvoiceReservation( request => $request );

	ok( $response->wasSuccessful(), "Successfull invoice reservation" )
	  or diag( "Invoice reservation failed: ", Dumper($response) );

	ok( $request->terminal() eq $response->getPrimaryPayment()->xml()->{Terminal} );
	ok( $request->orderId() eq $response->getPrimaryPayment()->xml()->{ShopOrderId} );
	ok( 0 == $response->getPrimaryPayment()->xml()->{CapturedAmount} );
	ok( $request->amount() == $response->getPrimaryPayment()->xml()->{ReservedAmount} );

	ok( $request->customerInfo()->email() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Email});
	ok( $request->customerInfo()->billingAddress()->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Address} );
	ok( $request->customerInfo()->billingAddress()->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{PostalCode} );
};

subtest 'Test invoice reservation request with all parameters' => sub {

	my $transactionInfo = { info1 => 'desc1', info2 => 'desc2' };

	my $lines = new Pensio::Request::OrderLines();

	$lines->add(
		description => "description 1",
		itemId      => "id 01",
		quantity    => 1,
		unitPrice   => 1.1,
		taxPercent	=> 11,
		taxAmount	=> 22,
		unitCode	=> "kg",
		discount	=> 33,
		goodsType   => "item",
		imageUrl	=> "image url"
	);

	$lines->add(
		description => "description 2",
		itemId      => "id 02",
		quantity    => 2,
		unitPrice   => 2.2,
		goodsType   => "item"
	);

	my $ci = new Pensio::Request::CustomerInfo();

	$ci->email('myuser@mymail.com');
	$ci->username("myuser");
	$ci->customerPhone("20123456");

	$ci->gender("M");
	$ci->ipAddress("1.1.1.1");
	$ci->clientSessionId("id00001");
	$ci->clientAcceptLanguage("en");
	$ci->clientUserAgent("user agent");
	$ci->clientForwardedIp("2.2.2.2");
	
	$ci->shippingAddress()->firstName('ship first');
	$ci->shippingAddress()->lastName('ship last');
	$ci->shippingAddress()->address('ship address');
	$ci->shippingAddress()->city('ship city');
	$ci->shippingAddress()->region('ship region');
	$ci->shippingAddress()->postalCode('1111');
	$ci->shippingAddress()->country('DK');

	$ci->billingAddress()->firstName('bil first');
	$ci->billingAddress()->lastName('bil last');
	$ci->billingAddress()->address('bil address');
	$ci->billingAddress()->city('bil city');
	$ci->billingAddress()->region('bil region');
	$ci->billingAddress()->postalCode('2222');
	$ci->billingAddress()->country('BR');

	my $request = new Pensio::Request::CreateInvoiceReservationRequest(
		terminal => 'AltaPay Test Invoice Terminal DK',
		orderId  => 'CreateInvoiceReservationTest_' . Pensio::Examples::getRandomOrderId(),
		amount   => 42.0,
		currency => 'DKK',
		transactionInfo     => $transactionInfo,
		authType            => 'paymentAndCapture',
		accountNumber		=> '1111',
		bankCode			=> '2222',
		paymentSource       => 'mobi',
		fraudService        => 'maxmind',
		organisationNumber	=> '3333',
		personalIdentifyNumber => '4444',
		birthDate			=> '2017-12-30',
		orderLines          => $lines,
		customerInfo		=> $ci
	);

	my $response = $api->createInvoiceReservation( request => $request );

	ok( $response->wasSuccessful(), "Successfull invoice reservation" )
	  or diag( "Invoice reservation with all parameters failed: ", Dumper($response) );
	  
	ok( $request->terminal() eq $response->getPrimaryPayment()->xml()->{Terminal});
	ok( $request->orderId() eq $response->getPrimaryPayment()->xml()->{ShopOrderId});
	ok( $request->authType() eq $response->getPrimaryPayment()->xml()->{AuthType});
	ok( 0 == $response->getPrimaryPayment()->xml()->{CapturedAmount});
	ok( $request->amount() == $response->getPrimaryPayment()->xml()->{ReservedAmount});
	
	my $ship = $request->customerInfo()->shippingAddress();
	my $bil = $request->customerInfo()->billingAddress();
	
	ok( $ship->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Firstname});
	ok( $ship->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Lastname});
	ok( $ship->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Address});
	ok( $ship->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{City});
	ok( $ship->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Region});
	ok( $ship->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{PostalCode});
	ok( $ship->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Country});
	
	ok( $bil->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Firstname});
	ok( $bil->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Lastname});
	ok( $bil->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Address});
	ok( $bil->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{City});
	ok( $bil->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Region});
	ok( $bil->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{PostalCode});
	ok( $bil->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Country});
	
	ok( $request->customerInfo()->email() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Email});
	ok( $request->customerInfo()->username() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Username});
	ok( $request->customerInfo()->customerPhone() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{CustomerPhone});
	
	ok( $request->customerInfo()->gender() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Gender});
	ok( $request->customerInfo()->clientUserAgent() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{UserAgent});
	ok( $request->customerInfo()->ipAddress() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{IpAddress});
	
	ok( $request->transactionInfo()->{info1} eq $response->getPrimaryPayment()->getPaymentInfo('info1'));
	ok( $request->transactionInfo()->{info2} eq $response->getPrimaryPayment()->getPaymentInfo('info2'));
};
