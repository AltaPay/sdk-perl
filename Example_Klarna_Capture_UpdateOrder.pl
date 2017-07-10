#!/usr/bin/perl
#
# Klarna test script.
#
#
package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Pensio::Request::CaptureRequest;
use Pensio::Request::UpdateOrderRequest;
use Pensio::Request::OrderLines;
use Data::Dumper;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

# CAPTURE: =============================================================================

my $paymentId = '157'; # PUT A PAYMENT ID FROM A PREVIOUSLY CREATED ORDER HERE
	
my $request = new Pensio::Request::CaptureRequest(paymentId=>$paymentId);
	
my $response = $api->capture(request => $request);
	
if (!$response->wasSuccessful()) {
	print("Capture was declined: " . $response->getMerchantErrorMessage() . "\n");
}

# UPDATE ORDER: ========================================================================

my $lines = new Pensio::Request::OrderLines();

$lines->add(
	description => "description 1",
	itemId => "id 01",
	quantity => -1,
	unitPrice => 1.1,
	goodsType => "item"
);

$lines->add(
	description => "new item",
	itemId => "new id",
	quantity => 1,
	unitPrice => 1.1,
	goodsType => "item"
);

$request = new Pensio::Request::UpdateOrderRequest (paymentId=>$paymentId, orderLines=>$lines);

$request->orderLines()->add(
	description => "description 1",
	itemId => "id 01",
	quantity => -1,
	unitPrice => 1.1,
	goodsType => "item"
);

$request->orderLines()->add(
	description => "new item",
	itemId => "new id",
	quantity => 1,
	unitPrice => 1.1,
	goodsType => "item"
);

$response = $api->updateOrder(request => $request);

if (!$response->wasSuccessful()) {
	print("Update order error: " . $response->getErrorMessage() . "\n");
	print("Update order error code: " . $response->getErrorCode());
}
else {
	print("Update order: successful!");
}

