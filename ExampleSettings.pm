package ExampleSettings;

use strict;

our $installation_url              = 'https://testgateway.pensio.com';
our $username                      = 'api@merchantdomain.com';
our $password                      = 'password-xxx';
our $altapay_klarna_terminal       = 'Merchant Klarna Terminal Name';
our $altapay_test_terminal         = "Merchant Test Terminal Name";
our $altapay_invoice_test_terminal = "Merchant Invoice Terminal Name";

sub new { bless {}, shift }

sub altapay_klarna_terminal       { $altapay_klarna_terminal }
sub altapay_test_terminal         { $altapay_test_terminal }
sub altapay_invoice_test_terminal { $altapay_invoice_test_terminal }
sub username                      { $username }
sub password                      { $password }
sub installation_url              { $installation_url }

sub getRandomOrderId {
    my @chars = ("A" .. "Z", "a" .. "z");
    my $string;
    $string .= $chars[rand @chars] for 1 .. 8;

    return $string;
}

1;
