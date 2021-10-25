#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::ReservationRequest;
use Pensio::Request::CustomerInfo;
use Pensio::Request::OrderLines;
use Data::Dumper;
use Test::More tests => 5;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);

sub createReservation {

    my ($amount) = @_;

    my $request = new Pensio::Request::ReservationRequest(
        terminal    => $api_settings_obj->altapay_test_terminal,
        orderId     => "ReservationTest_" . $api_settings_obj->getRandomOrderId(),
        amount      => $amount,
        currency    => 'EUR',
        pan         => '4111000011110000',
        expiryMonth => 1,
        expiryYear  => 2018,
        cvc         => '123'
    );

    return $request;
}

sub createReservationWithToken {

    my ($amount, $creditCardToken) = @_;

    my $request = new Pensio::Request::ReservationRequest(
        terminal        => $api_settings_obj->altapay_test_terminal,
        orderId         => "ReservationTest_" . $api_settings_obj->getRandomOrderId(),
        amount          => $amount,
        currency        => 'EUR',
        creditCardToken => $creditCardToken,
        cvc             => '123'
    );

    return $request;
}

subtest 'Test successful reservation' => sub {

    my $request = createReservation(42.0);

    my $response = $api->reservation(request => $request);

    ok($response->wasSuccessful(), "Successfull reservation")
      or diag("Reservation failed: ", Dumper($response));
};

subtest 'Test failed reservation' => sub {

    my $request = createReservation(5.66);

    my $response = $api->reservation(request => $request);

    ok($response->wasDeclined(), "Failed reservation")
      or diag("Error testing a failed reservation: ", Dumper($response));
};

subtest 'Test erroneous reservation' => sub {

    my $request = createReservation(5.67);

    my $response = $api->reservation(request => $request);

    ok($response->wasErroneous(), "Erroneous reservation")
      or diag("Error testing a erroneous reservation: ", Dumper($response));
};

subtest 'Test successful reservation using token' => sub {

    my $request = createReservation(42.0);
    my $response = $api->reservation(request => $request);

    my $request2 = createReservationWithToken(42.0, $response->getPrimaryPayment()->xml()->{CreditCardToken});
    my $response2 = $api->reservation(request => $request2);

    ok($response2->wasSuccessful(), "Reservation using token")
      or diag("Error testing a reservation using token: ", Dumper($response2));
};

subtest 'Test reservation using all parameters' => sub {

    my $transactionInfo = {info1 => 'desc1', info2 => 'desc2'};

    my $lines = new Pensio::Request::OrderLines();

    $lines->add(
        description => "description 1",
        itemId      => "id 01",
        quantity    => 1,
        unitPrice   => 1.1,
        goodsType   => "item"
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

    my $request = new Pensio::Request::ReservationRequest(
        terminal            => $api_settings_obj->altapay_test_terminal,
        orderId             => "ReservationTest_" . $api_settings_obj->getRandomOrderId(),
        amount              => 42.0,
        currency            => 'EUR',
        pan                 => '4111000011110000',
        expiryMonth         => 1,
        expiryYear          => 2018,
        cvc                 => '123',
        transactionInfo     => $transactionInfo,
        authType            => 'paymentAndCapture',
        paymentSource       => 'mobi',
        fraudService        => 'maxmind',
        surcharge           => 0,
        customerCreatedDate => '2017-12-30',
        shippingMethod      => 'DesignatedByCustomer',
        orderLines          => $lines,
        customerInfo        => $ci
    );

    my $response = $api->reservation(request => $request);

    ok($response->wasSuccessful(), "Reservation using all parameters")
      or diag("Error testing a reservation using all parameters: ", Dumper($response));

    ok($request->terminal() eq $response->getPrimaryPayment()->xml()->{Terminal});
    ok($request->orderId() eq $response->getPrimaryPayment()->xml()->{ShopOrderId});
    ok($request->authType() eq $response->getPrimaryPayment()->xml()->{AuthType});
    ok($request->amount() == $response->getPrimaryPayment()->xml()->{CapturedAmount});
    ok($request->amount() == $response->getPrimaryPayment()->xml()->{ReservedAmount});
    ok('411100******0000' eq $response->getPrimaryPayment()->xml()->{CreditCardMaskedPan});
    ok($request->expiryMonth() == $response->getPrimaryPayment()->xml()->{CreditCardExpiry}->{Month});
    ok($request->expiryYear() == $response->getPrimaryPayment()->xml()->{CreditCardExpiry}->{Year});

    my $ship = $request->customerInfo()->shippingAddress();
    my $bil  = $request->customerInfo()->billingAddress();

    ok($ship->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Firstname});
    ok($ship->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Lastname});
    ok($ship->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Address});
    ok($ship->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{City});
    ok($ship->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Region});
    ok($ship->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{PostalCode});
    ok($ship->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{ShippingAddress}->{Country});

    ok($bil->firstName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Firstname});
    ok($bil->lastName() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Lastname});
    ok($bil->address() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Address});
    ok($bil->city() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{City});
    ok($bil->region() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Region});
    ok($bil->postalCode() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{PostalCode});
    ok($bil->country() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{BillingAddress}->{Country});

    ok($request->customerInfo()->email() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Email});
    ok($request->customerInfo()->username() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{Username});
    ok($request->customerInfo()->customerPhone() eq $response->getPrimaryPayment()->xml()->{CustomerInfo}->{CustomerPhone});

    ok($request->transactionInfo()->{info1} eq $response->getPrimaryPayment()->getPaymentInfo('info1'));
    ok($request->transactionInfo()->{info2} eq $response->getPrimaryPayment()->getPaymentInfo('info2'));

};
