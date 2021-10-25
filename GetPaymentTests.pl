#!/usr/bin/perl
package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::GetPaymentRequest;
use Pensio::Request::InitiatePaymentRequest;
use Data::Dumper;
use Test::More tests => 2;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

sub initiatePayment {

    my $request = new Pensio::Request::InitiatePaymentRequest(
        amount   => 2.33,
        orderId  => "release_" . $api_settings_obj->getRandomOrderId(),
        terminal => $api_settings_obj->altapay_test_terminal,
        currency => 'EUR',
        cardnum  => '4111000011110000',
        emonth   => '03',
        eyear    => '2042',
    );

    my $initiateResponse = $api->initiatePayment(request => $request);

    ok($initiateResponse->wasSuccessful(), "Successful PaymentRequest initiate!")
      or diag("Initiate before capture failed..: ", Dumper($initiateResponse));

    return $initiateResponse->getPrimaryPayment()->getId();
}

my $request = new Pensio::Request::GetPaymentRequest(paymentId => initiatePayment());

sleep(3);

my $response = $api->getPayment(request => $request);

ok($response->wasSuccessful(), "Successful get payment!")
  or diag("get payment failed: ", Dumper($response));

