#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::ReservationRequest;
use Pensio::Request::SetupSubscriptionRequest;
use Pensio::Request::ReserveSubscriptionChargeRequest;
use Pensio::Request::CaptureRequest;
use Pensio::Request::ChargeSubscriptionRequest;
use Data::Dumper;
use Test::More tests => 2;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);

sub createReservation {

    my ($amount) = @_;

    my $request = new Pensio::Request::ReservationRequest(
        terminal    => $api_settings_obj->altapay_test_terminal,
        orderId     => "AgreementTest_R_UI_" . $api_settings_obj->getRandomOrderId(),
        amount      => $amount,
        currency    => 'EUR',
        pan         => '4111000011110000',
        expiryMonth => 1,
        expiryYear  => 2045,
        cvc         => '123',

    );

    return $request;
}

sub createSubscription {

    my ($amount) = @_;

    my $request = new Pensio::Request::SetupSubscriptionRequest(
        terminal    => $api_settings_obj->altapay_test_terminal,
        orderId     => "AgreementTest_S_UI_" . $api_settings_obj->getRandomOrderId(),
        amount      => $amount,
        currency    => 'DKK',
        pan         => '4111000011110000',
        expiryMonth => 1,
        expiryYear  => 2045,
        cvc         => '123',
    );

    $request->agreementConfig()->agreementType('unscheduled');
    $request->agreementConfig()->agreementUnscheduledType('incremental');

    return $request;
}


subtest 'Test successful agreement setup & charge using reservation & capture' => sub {

    my $request = createReservation(999.0);
    $request->authType('subscription');
    $request->agreementConfig()->agreementType('unscheduled');
    $request->agreementConfig()->agreementUnscheduledType('incremental');

    my $response = $api->reservation(request => $request);
    ok($response->wasSuccessful(), "Successful reservation")
        or diag("Reservation failed: ", Dumper($response));

    my $sr = new Pensio::Request::ReserveSubscriptionChargeRequest(
        amount                   => 3.33,
        agreementId              => $response->getPrimaryPayment()->xml()->{TransactionId},
        agreementUnscheduledType => 'incremental'
    );
    my $res = $api->reserveSubscriptionCharge('request' => $sr);

    ok($res->wasSuccessful(), "Successful reserve subscription charge")
        or diag("reserve subscription charge failed: ", Dumper($res));


    my $cr = new Pensio::Request::CaptureRequest(
        amount    => 3.33,
        paymentId => $res->getLatestPayment()->xml()->{TransactionId}
    );

    my $resp = $api->capture('request' => $cr);
    ok($resp->wasSuccessful(), "Successful capture subscription")
        or diag("subscription capture failed: ", Dumper($resp));

};

subtest 'Test successful agreement setup & charge using subscription endpoints' => sub {

    my $request = createSubscription(99.0);

    my $response = $api->setupSubscription(request => $request);
    ok($response->wasSuccessful(), "Successful agreement setup using setupSubscription")
        or diag("setupSubscription failed: ", Dumper($response));

    my $sr = new Pensio::Request::ChargeSubscriptionRequest(
        amount                   => 3.33,
        agreementId              => $response->getLatestPayment()->xml()->{TransactionId},
        agreementUnscheduledType => 'incremental'
    );
    my $res = $api->chargeSubscription('request' => $sr);

    ok($res->wasSuccessful(), "Successful agreement charge using chargeSubscription")
        or diag("chargeSubscription failed: ", Dumper($res));

};