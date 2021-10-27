#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Pensio::PensioAPI;
use Data::Dumper;
use Test::More tests => 1;

my $api_settings_obj = ExampleSettings->new();
my $api = new Pensio::PensioAPI($api_settings_obj->installation_url, $api_settings_obj->username, $api_settings_obj->password);

$api->setLogger(new ExampleStdoutLogger());
my $response = $api->login();

ok($response->wasSuccessful(), "Successful login!") or diag("login failed: ", Dumper($response));