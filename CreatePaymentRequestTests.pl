#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CreatePaymentRequestRequest;
use Data::Dumper;
use Test::More tests => 3;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

my $pay_request = new Pensio::Request::CreatePaymentRequestRequest(
    amount   => 2.33,
    orderId  => $api_settings_obj->getRandomOrderId(),
    terminal => $api_settings_obj->altapay_test_terminal,
    currency => 'EUR',

);

my $response = $api->createPaymentRequest( request => $pay_request );

ok( $response->wasSuccessful(), "Created payment request succesfully!" )
  or diag( "Create payment request failed..: ", Dumper($response) );

note( $response->getUrl() );

my $request = new Pensio::Request::CreatePaymentRequestRequest(
    amount   => 2.33,
    orderId  => $api_settings_obj->getRandomOrderId(),
    terminal => $api_settings_obj->altapay_test_terminal,
    currency => 'EUR',
    language => "da",
    type     => 'paymentAndCapture',

    #creditCardToken=>'hat',
    saleReconciliationIdentifier => 'testidentifier',
    cookie                => 'PHPSESSID=asdfasdfdf23; mycookie=mycookievalue',
    fraudService          => 'test',
    shippingMethod        => 'Military',
    customer_created_date => '2013-01-02',
    organisationNumber    => '654321',
    accountOffer          => 'required',
);

$request->config()->callbackForm("http://www.form.com/");
$request->config()->callbackOk("http://www.okay.com/");
$request->config()->callbackFail("http://www.fail.com/");
$request->config()->callbackRedirect("http://www.redirect.com/");
$request->config()->callbackOpen("http://www.open.com/");
$request->config()->callbackNotification("http://www.notification.com/");
$request->config()->callbackVerifyOrder("http://www.verify.order.com/");

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
$request->customerInfo()->shippingAddress()->country('DK');

$request->customerInfo()->billingAddress()->firstName('Jane');
$request->customerInfo()->billingAddress()->lastName('Doe');
$request->customerInfo()->billingAddress()->address('Anywhere Street 24');
$request->customerInfo()->billingAddress()->city('Any City');
$request->customerInfo()->billingAddress()->region('A Region');
$request->customerInfo()->billingAddress()->postalCode('12345');
$request->customerInfo()->billingAddress()->country('DK');

$request->orderLines()->add(
    description => "Product 1",
    itemId      => "Product id 1",
    quantity    => 1.24,
    taxPercent  => 20.0,
    unitCode    => "kg",
    unitPrice   => 123.42,
    discount    => 0.42,
    goodsType   => "item",
    taxAmount   => 44.33
);

$request->orderLines()->add(
    description => "Product 2",
    itemId      => "Product id 2",
    quantity    => 4,
    taxPercent  => 25.0,
    unitCode    => "",
    unitPrice   => 15423.42,
    discount    => 52.54,
    goodsType   => "item",
    taxAmount   => 65.55
);

$response = $api->createPaymentRequest( request => $request );

ok( $response->wasSuccessful(), "Created payment request with loads of data!" )
  or diag( "Created payment request with loads of data failed..: ", Dumper($response) );

note( $response->getUrl() );

my $agreement_request = new Pensio::Request::CreatePaymentRequestRequest(
    amount   => 7.33,
    orderId  => $api_settings_obj->getRandomOrderId(),
    terminal => $api_settings_obj->altapay_test_terminal,
    currency => 'EUR',

);

$agreement_request->authType('subscription');

$agreement_request->agreementConfig()->agreementType('unscheduled');
$agreement_request->agreementConfig()->agreementUnscheduledType('incremental');
my $agreement_response = $api->createPaymentRequest( request => $agreement_request );

ok( $agreement_response->wasSuccessful(), "Created payment request with agreement setup successfully!" )
    or diag( "Create payment request with agreement setup failed..: ", Dumper($agreement_response) );

note( $agreement_response->getUrl() );