#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::RefundRequest;
use Pensio::Request::CaptureRequest;
use Pensio::Request::InitiatePaymentRequest;
use Data::Dumper;
use Test::More tests => 4;

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
        orderId  => "refund_" . $api_settings_obj->getRandomOrderId(),
        terminal => $api_settings_obj->altapay_test_terminal,
        currency => 'EUR',
        cardnum  => $cardnum,
        emonth   => '03',
        eyear    => '2042',
    );

    my $initiateResponse = $api->initiatePayment(request => $request);

    ok($initiateResponse->wasSuccessful(), "Successfull initiate!")
      or diag("Initiate before capture failed..: ", Dumper($initiateResponse));

    return $initiateResponse->getPrimaryPayment()->getId();
}

sub capture {
    my ($paymentId) = @_;

    my $request = new Pensio::Request::CaptureRequest(
        amount    => 2.33,
        paymentId => $paymentId
    );

    my $response = $api->capture(request => $request);

    ok($response->wasSuccessful(), "Successfull capture!")
      or diag("Capture failed..: ", Dumper($response));
}

sub refund {

    my ($paymentId, $amount, $allowOverRefund) = @_;

    if (not defined $allowOverRefund) {
        $allowOverRefund = 0;
    }
    if (not defined $amount) {
        $amount = 2.33;
    }

    my $request = new Pensio::Request::RefundRequest(
        amount                   => $amount,
        paymentId                => $paymentId,
        reconciliationIdentifier => "my local id",
        allowOverRefund          => $allowOverRefund
    );

    my $response = $api->refund(request => $request);

    return $response;
}

subtest 'Refund test' => sub {

    my $paymentId = initiatePayment();

    capture($paymentId);

    my $response = refund($paymentId);

    ok($response->wasSuccessful(), "Successfull refund!")
      or diag("Refund failed..: ", Dumper($response));
};

subtest 'Over Refund test' => sub {

    my $paymentId = initiatePayment();

    capture($paymentId);

    my $response = refund($paymentId, 10, 1);

    ok($response->wasSuccessful(), "Successfull refund!")
      or diag("Over refund failed..: ", Dumper($response));
};

subtest 'Refund declined test' => sub {

    my $paymentId = initiatePayment('4111000011110966');

    capture($paymentId);

    my $response = refund($paymentId);

    ok(!$response->wasSuccessful(), "Declined refund!")
      or diag("Refund did not fail..: ", Dumper($response));

    is($response->getMerchantErrorMessage(), "TestAcquirer[pan=0966 or amount=9660]", "Correct error message");
};

subtest 'Refund error test' => sub {

    my $paymentId = initiatePayment('4111000011110967');

    capture($paymentId);

    my $response = refund($paymentId);

    ok(!$response->wasSuccessful(), "Failing refund!")
      or diag("Refund did not fail..: " . Dumper($response));

    is($response->getMerchantErrorMessage(), "TestAcquirer[pan=0967 or amount=9670]", "Correct error message");

};