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

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

sub createRequest {
    my ($ci) = @_;

    my $request = new Pensio::Request::CreateInvoiceReservationRequest(
        terminal     => $api_settings_obj->altapay_invoice_test_terminal,
        orderId      => 'CreateInvoiceReservationTest_' . $api_settings_obj->getRandomOrderId(),
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

    my $response = $api->createInvoiceReservation(request => $request);

    ok($response->wasSuccessful(), "Successfull invoice reservation")
      or diag("Invoice reservation failed: ", Dumper($response));

    ok($request->terminal() eq $response->getPrimaryPayment()->xml()->{Terminal},     "Correct Terminal Found: " . $request->terminal());
    ok($request->orderId() eq $response->getPrimaryPayment()->xml()->{ShopOrderId},   "Correct ShopOrderId Found: " . $request->orderId());
    ok(0 == $response->getPrimaryPayment()->xml()->{CapturedAmount},                  "Correct CapturedAmount Found: 0");
    ok($request->amount() == $response->getPrimaryPayment()->xml()->{ReservedAmount}, "Correct ReservedAmount Found: " . $request->amount());

    ok($request->customerInfo()->email() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Email},                                               "Correct Email Found: " . $request->customerInfo()->email());
    ok($request->customerInfo()->billingAddress()->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Address},       "Correct BillingAddress Found: " . $request->customerInfo()->billingAddress()->address());
    ok($request->customerInfo()->billingAddress()->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{PostalCode}, "Correct postalCode Found: " . $request->customerInfo()->billingAddress()->postalCode());
};

subtest 'Test invoice reservation request with all parameters' => sub {

    my $transactionInfo = {info1 => 'desc1', info2 => 'desc2'};

    my $lines = new Pensio::Request::OrderLines();

    $lines->add(
        description => "description 1",
        itemId      => "id 01",
        quantity    => 1,
        unitPrice   => 1.1,
        taxPercent  => 11,
        taxAmount   => 22,
        unitCode    => "kg",
        discount    => 33,
        goodsType   => "item",
        imageUrl    => "image url"
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
        terminal               => $api_settings_obj->altapay_invoice_test_terminal,
        orderId                => 'CreateInvoiceReservationTest_' . $api_settings_obj->getRandomOrderId(),
        amount                 => 42.0,
        currency               => 'DKK',
        transactionInfo        => $transactionInfo,
        authType               => 'paymentAndCapture',
        accountNumber          => '1111',
        bankCode               => '2222',
        paymentSource          => 'mobi',
        fraudService           => 'maxmind',
        organisationNumber     => '3333',
        personalIdentifyNumber => '4444',
        birthDate              => '2017-12-30',
        orderLines             => $lines,
        customerInfo           => $ci
    );

    my $response = $api->createInvoiceReservation(request => $request);

    ok($response->wasSuccessful(), "Successful invoice reservation")
      or diag("Invoice reservation with all parameters failed: ", Dumper($response));

    ok($request->terminal() eq $response->getPrimaryPayment()->xml()->{Terminal},     "Correct firstName Found: " . $request->terminal());
    ok($request->orderId() eq $response->getPrimaryPayment()->xml()->{ShopOrderId},   "Correct orderId Found: " . $request->orderId());
    ok($request->authType() eq $response->getPrimaryPayment()->xml()->{AuthType},     "Correct authType Found: " . $request->authType());
    ok(0 == $response->getPrimaryPayment()->xml()->{CapturedAmount},                  "Correct CapturedAmount Found: 0");
    ok($request->amount() == $response->getPrimaryPayment()->xml()->{ReservedAmount}, "Correct ReservedAmount Found: " . $request->amount());

    #ship
    my $ship = $request->customerInfo()->shippingAddress();
    ok($ship->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Firstname},   "Correct firstName Found: " . $ship->firstName());
    ok($ship->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Lastname},     "Correct lastName Found: " . $ship->lastName());
    ok($ship->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Address},       "Correct address Found: " . $ship->address());
    ok($ship->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{City},             "Correct city Found: " . $ship->city());
    ok($ship->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Region},         "Correct region Found: " . $ship->region());
    ok($ship->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{PostalCode}, "Correct postalCode Found: " . $ship->postalCode());
    ok($ship->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Country},       "Correct country Found: " . $ship->country());

    #bill
    my $bil = $request->customerInfo()->billingAddress();
    ok($bil->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Firstname},   "Correct firstName Found: " . $bil->firstName());
    ok($bil->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Lastname},     "Correct lastName Found: " . $bil->lastName());
    ok($bil->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Address},       "Correct Address Found: " . $bil->address());
    ok($bil->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{City},             "Correct city address: " . $bil->city());
    ok($bil->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Region},         "Correct region Found: " . $bil->region());
    ok($bil->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{PostalCode}, "Correct postalCode Found: " . $bil->postalCode());
    ok($bil->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Country},       "Correct country Found: " . $bil->country());

    ok($request->customerInfo()->email() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Email},                 "Correct Email Found: " . $request->customerInfo()->email());
    ok($request->customerInfo()->username() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Username},           "Correct username Found: " . $request->customerInfo()->username());
    ok($request->customerInfo()->customerPhone() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{CustomerPhone}, "Correct customerPhone Found: " . $request->customerInfo()->customerPhone());

    ok($request->customerInfo()->gender() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Gender},             "Correct Gender Found: " . $request->customerInfo()->gender());
    ok($request->customerInfo()->clientUserAgent() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{UserAgent}, "Correct clientUserAgent Found: " . $request->customerInfo()->clientUserAgent());
    ok($request->customerInfo()->ipAddress() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{IpAddress},       "Correct ipAddress Found: " . $request->customerInfo()->ipAddress());

    ok($request->transactionInfo()->{info1} eq $response->getPrimaryPayment()->getPaymentInfo('info1'), "Correct transactionInfo Found: " . $request->transactionInfo()->{info1});
    ok($request->transactionInfo()->{info2} eq $response->getPrimaryPayment()->getPaymentInfo('info2'), "Correct transactionInfo Found: " . $request->transactionInfo()->{info2});

    ok("mobi" eq $response->getPrimaryPayment->xml->{PaymentSource}, "Correct PaymentSource Found: mobi");
};
