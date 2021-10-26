#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::InitiatePaymentRequest;
use Pensio::Request::Verify3DSecureRequest;
use Data::Dumper;
use Test::More tests => 5;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);
$api->setLogger(new ExampleStdoutLogger());


sub initiatePayment {
    my ($cardnum, $localTerminal, $fraudService) = @_;

    if (not defined $cardnum) {
        $cardnum = '4111000011110000';
    }
    if (not defined $localTerminal) {
        $localTerminal = $api_settings_obj->altapay_test_terminal;
    }

    if (not defined $fraudService) {
        $fraudService = 'none';
    }

    my $request = new Pensio::Request::InitiatePaymentRequest(
        amount          => 2.33,
        orderId         => "capture_" . $api_settings_obj->getRandomOrderId(),
        terminal        => $api_settings_obj->altapay_test_terminal,
        currency        => 'EUR',
        cardnum         => $cardnum,
        emonth          => '03',
        eyear           => '2042',
        fraudService    => $fraudService,
        transactionInfo => {info1 => 'test'}
    );

    if ($fraudService == 'test') {
        $request->orderLines->add(
            description => 'Test item 1',
            itemId      => 'itm1',
            quantity    => 3,
            taxPercent  => 0.43,
            unitCode    => 'kg',
            unitPrice   => 10.34,
            discount    => 0.34,
            goodsType   => 'item',
        );

        $request->orderLines->add(
            description => 'Test item 2',
            itemId      => 'itm2',
            quantity    => 1,
            taxPercent  => 0,
            unitCode    => '',
            unitPrice   => 34.22,
            discount    => 0,
            goodsType   => 'item',
        );
    }

    my $initiateResponse = $api->initiatePayment(request => $request);

    return $initiateResponse;
}

subtest 'Initiate regular payment test' => sub {
    my $initiateResponse = initiatePayment();

    ok($initiateResponse->wasSuccessful(), "Successful initiate!")
      or diag("Initiate failed..: ", Dumper($initiateResponse));
};

subtest 'Initiate regular declined payment test' => sub {
    my $initiateResponse = initiatePayment('4170000000000566');

    ok(!$initiateResponse->wasSuccessful(), "Declined initiate!")
      or diag("Initiate was not declined..: ", Dumper($initiateResponse));
};

subtest 'Initiate regular erred payment test' => sub {
    my $initiateResponse = initiatePayment('4170000000000567');

    ok(!$initiateResponse->wasSuccessful(), "Erred initiate!")
      or diag("Initiate was not erred..: ", Dumper($initiateResponse));
};

subtest 'Initiate 3d secure payment test' => sub {

    my $response = initiatePayment('4170000000000568', 'AltaPay Test 3DSecure Terminal');

    if ($response->was3DSecure()) {
        pass("Created 3D Secure payment successfully");

        note("3D-Secure CreditCard payment: ", $response->getRedirectUrl(), ", PaReq:", $response->getPaReq());

        my $verifyRequest = new Pensio::Request::Verify3DSecureRequest(
            paymentId => $response->getPrimaryPayment()->getId(),
            paRes     => 'WorkingPaRes',                            # This is a hack, you would normally get this posted back after sending the browser to the redirect URL
        );

        my $verifyResponse = $api->verify3DSecure(request => $verifyRequest);

        ok($verifyResponse->wasSuccessful(), "Successful 3D-Secure CreditCard payment!")
          or diag("3D-Secure Validation failed..: ", Dumper($verifyResponse));
    } else {
        fail("Did not create 3D Secure payment successfully");
    }
};

subtest 'Initiate with fraud check test' => sub {
    my $initiateResponse = initiatePayment('4170000000000000', $api_settings_obj->altapay_test_terminal, 'test');

    ok($initiateResponse->wasSuccessful(), "Initiate success!")
      or diag("Initiate was not erred..: ", Dumper($initiateResponse));

    my @payments = $initiateResponse->getPayments();

    ok($payments[0]->xml->{FraudRecommendation} == "Challenge", "Fraud response correct")
      or diag("Fraud recommendation was not set to challenge: ", Dumper($initiateResponse));
};
