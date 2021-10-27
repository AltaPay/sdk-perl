#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::CaptureRequest;
use Data::Dumper;
use Test::More tests => 5;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

sub initiatePayment {
    my ($cardnum) = @_;

    if (not defined $cardnum) {
        $cardnum = '4111000011110000';
    }

    my $request = new Pensio::Request::InitiatePaymentRequest(
        amount   => 2.33,
        orderId  => "capture_" . $api_settings_obj->getRandomOrderId(),
        terminal =>  $api_settings_obj->altapay_test_terminal,
        currency => 'EUR',
        cardnum  => $cardnum,
        emonth   => '03',
        eyear    => '2042',
    );

    my $initiateResponse = $api->initiatePayment(request => $request);

    ok($initiateResponse->wasSuccessful(), "Successful initiate!")
      or diag("Initiate before capture failed..: ", Dumper($initiateResponse));

    return $initiateResponse->getPrimaryPayment()->getId();
}

subtest 'Capture success test' => sub {

    my $paymentId = initiatePayment();

    my $request = new Pensio::Request::CaptureRequest(amount => 2.33, paymentId => $paymentId);

    my $response = $api->capture(request => $request);

    ok($response->wasSuccessful(), "Successful capture!")
      or diag("Capture failed..: ", Dumper($response));

};

subtest 'Capture amount less than reserved' => sub {

    my $paymentId = initiatePayment();

    my $captured_amount = 1.33;                                                                               # less than the reserved amount 2.33
    my $request = new Pensio::Request::CaptureRequest(amount => $captured_amount, paymentId => $paymentId);

    my $response = $api->capture(request => $request);

    ok($response->wasSuccessful(), "Successful capture!")
      or diag("Capture failed..: ", Dumper($response));
    my $first_payment = shift @{$response->payments};
    is($first_payment->{xml}{CapturedAmount}, $captured_amount, 'Response - captured amount');
};

subtest 'Capture declined test' => sub {

    my $paymentId = initiatePayment("4111000011110766");

    my $request = new Pensio::Request::CaptureRequest(amount => 2.33, paymentId => $paymentId);

    my $response = $api->capture(request => $request);

    ok(!$response->wasSuccessful(), "Declined capture!")
      or diag("Capture was not declined: ", Dumper($response));
};

subtest 'Capture error test' => sub {

    my $paymentId = initiatePayment("4111000011110767");

    my $request = new Pensio::Request::CaptureRequest(amount => 2.33, paymentId => $paymentId);

    my $response = $api->capture(request => $request);

    ok(!$response->wasSuccessful(), "Erred capture!")
      or diag("Capture was not erred: ", Dumper($response));
};

subtest 'Capture success with loads of data test' => sub {

    my $paymentId = initiatePayment();

    my $request = new Pensio::Request::CaptureRequest(
        amount                   => 2.33,
        paymentId                => $paymentId,
        reconciliationIdentifier => "my local id",
        invoiceNumber            => "my invoice number",
        salesTax                 => 12.3
    );

    $request->orderLines()->add(
        description => "Product 1",
        itemId      => "Product id 1",
        quantity    => 1.24,
        taxPercent  => 20.0,
        unitCode    => "kg",
        unitPrice   => 123.42,
        discount    => 0.42,
        goodsType   => "item",
        taxAmount   => 788.99
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
        taxAmount   => 55.60
    );

    my $response = $api->capture(request => $request);

    ok($response->wasSuccessful(), "Successful capture with all options enabled!")
      or diag("Capture failed..: ", Dumper($response));
};
