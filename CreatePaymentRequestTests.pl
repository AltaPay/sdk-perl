#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CreatePaymentRequestRequest;
use Data::Dumper;
use Test::More tests => 2;



my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());


my $request = new Pensio::Request::CreatePaymentRequestRequest(
	amount=>2.33, 
	orderId=> Pensio::Examples::getRandomOrderId(),
	terminal=>$terminal,
	currency=>'EUR',
	
);

my $response = $api->createPaymentRequest(request => $request);

ok ($response->wasSuccessful(), "Created payment request succesfully!")
	or diag("Created payment request failed..: ",Dumper($response));
	
note($response->getUrl());


my $request = new Pensio::Request::CreatePaymentRequestRequest(
	amount=>2.33, 
	orderId=> Pensio::Examples::getRandomOrderId(),
	terminal=>$terminal,
	currency=>'EUR',
	language=>"da",
	type=>'paymentAndCapture',
	creditCardToken=>'hat',
	saleReconciliationIdentifier=>'testidentifier',
	cookie=>'PHPSESSID=asdfasdfdf23; mycookie=mycookievalue',
	fraudService=>'test',
	shippingMethod=>'Military',
	customer_created_date=>'2013-01-02',
	organisationNumber=>'654321',
	accountOffer=>'required',
);

$request->config()->callbackForm("http://my.form.callback/");
$request->config()->callbackOk("http://my.okay.callback/");
$request->config()->callbackFail("http://my.fail.callback/");
$request->config()->callbackRedirect("http://my.redirect.callback/");
$request->config()->callbackOpen("http://my.open.callback/");
$request->config()->callbackNotification("http://my.notification.callback/");
$request->config()->callbackVerifyOrder("http://my.verify.order.callback/");

$request->customerInfo()->email('this@email.com');
$request->customerInfo()->username("theusername");
$request->customerInfo()->customerPhone("+45 11 22 33 44");
$request->customerInfo()->bankName("The real bank");
$request->customerInfo()->bankPhone("+45 44 33 22 11");

$request->customerInfo()->shippingAddress()->firstName('John');
$request->customerInfo()->shippingAddress()->lastName('Doe');
$request->customerInfo()->shippingAddress()->address('Anywhere Street 23');
$request->customerInfo()->shippingAddress()->city('Any City');
$request->customerInfo()->shippingAddress()->region('A Region');
$request->customerInfo()->shippingAddress()->postalCode('12345');
$request->customerInfo()->shippingAddress()->country('Some Country');

$request->customerInfo()->billingAddress()->firstName('Jane');
$request->customerInfo()->billingAddress()->lastName('Doe');
$request->customerInfo()->billingAddress()->address('Anywhere Street 24');
$request->customerInfo()->billingAddress()->city('Any City');
$request->customerInfo()->billingAddress()->region('A Region');
$request->customerInfo()->billingAddress()->postalCode('12345');
$request->customerInfo()->billingAddress()->country('Some Country');

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

$response = $api->createPaymentRequest(request => $request);

ok ($response->wasSuccessful(), "Created payment request with loads of data!")
	or diag("Created payment request with loads of data failed..: ",Dumper($response));
	
note($response->getUrl());

