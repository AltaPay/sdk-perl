#!/usr/bin/perl
#
# Klarna test script.
#
#
package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CreatePaymentRequestRequest;
use Data::Dumper;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

my $request = new Pensio::Request::CreatePaymentRequestRequest(
    amount   => 5.5,
    orderId  => 'Example_Klarna_' . $api_settings_obj->getRandomOrderId(),
    terminal =>  $api_settings_obj->altapay_klarna_terminal,
    currency => 'DKK',
    authType => 'payment'

);

$request->customerInfo()->email('myuser@mymail.com');
$request->customerInfo()->username("myuser");
$request->customerInfo()->customerPhone("20123456");
$request->customerInfo()->bankName("My Bank");
$request->customerInfo()->bankPhone("+45 12-34 5678");

$request->customerInfo()->shippingAddress()->firstName('Testperson-dk');
$request->customerInfo()->shippingAddress()->lastName('Approved');
$request->customerInfo()->shippingAddress()->address('Sæffleberggate 56,1 mf');
$request->customerInfo()->shippingAddress()->city('Varde');
$request->customerInfo()->shippingAddress()->region('DK');
$request->customerInfo()->shippingAddress()->postalCode('6800');
$request->customerInfo()->shippingAddress()->country('DK');

$request->customerInfo()->billingAddress()->firstName('Testperson-dk');
$request->customerInfo()->billingAddress()->lastName('Approved');
$request->customerInfo()->billingAddress()->address('Sæffleberggate 56,1 mf');
$request->customerInfo()->billingAddress()->city('Varde');
$request->customerInfo()->billingAddress()->region('DK');
$request->customerInfo()->billingAddress()->postalCode('6800');
$request->customerInfo()->billingAddress()->country('DK');

$request->orderLines()->add(
    description => "description 1",
    itemId      => "id 01",
    quantity    => 1,
    unitPrice   => 1.1,
    goodsType   => "item"
);

$request->orderLines()->add(
    description => "description 2",
    itemId      => "id 02",
    quantity    => 2,
    unitPrice   => 2.2,
    goodsType   => "item"
);

my $response = $api->createPaymentRequest( request => $request );

if ( $response->wasSuccessful() ) {
    print("Created payment request succesfully!\n");
	ok($response->wasSuccessful(),"Payment created sucessfully")
} else {
    print("Created payment request failed..: \n" . Dumper($response));
}

# Access the url below and use the social security number 0801363945 in the page form to complete the Klarna order
print( $response->getUrl() );

