#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Data::Dumper;
use Test::More tests=>1;

my $api = new Pensio::PensioAPI($installation_url, $username, $password);
$api->setLogger(new ExampleStdoutLogger());

my $response = $api->login();

ok ($response->wasSuccessful(), "Successfull login!")
	or diag("login failed: ",Dumper($response));

