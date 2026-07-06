#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CheckoutSessionRequest;
use Data::Dumper;
use Test::More tests => 2;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());

subtest 'Create checkout session with single terminal' => sub {
    my $request = new Pensio::Request::CheckoutSessionRequest(
        terminals   => [$api_settings_obj->altapay_test_terminal],
        shopOrderId => $api_settings_obj->getRandomOrderId(),
        amount      => 2.33,
        currency    => 'EUR',
    );

    my $response = $api->checkoutSession(request => $request);

    ok($response->wasSuccessful(), "Created checkout session successfully!")
      or diag("Create checkout session failed..: ", Dumper($response));

    note("Session ID: ", $response->getSessionId());
    note("Session Status: ", $response->getSessionStatus());
};

subtest 'Create checkout session with multiple terminals' => sub {
    my $request = new Pensio::Request::CheckoutSessionRequest(
        terminals   => [$api_settings_obj->altapay_test_terminal, $api_settings_obj->altapay_invoice_test_terminal],
        shopOrderId => $api_settings_obj->getRandomOrderId(),
        amount      => 2.33,
        currency    => 'EUR',
    );

    my $response = $api->checkoutSession(request => $request);

    ok($response->wasSuccessful(), "Created checkout session with multiple terminals successfully!")
      or diag("Create checkout session with multiple terminals failed..: ", Dumper($response));

    note("Session ID: ", $response->getSessionId());
    note("Session Status: ", $response->getSessionStatus());
};
