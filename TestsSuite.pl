#!/usr/bin/perl

use TAP::Harness;
use TAP::Formatter::JUnit;
use Getopt::Long;
use Data::Dumper;

$|++;

my @tests = (
	'LoginTests.pl',
	'InitiatePaymentTests.pl',
	'CreatePaymentRequestTests.pl',
	'ReleaseTests.pl',
	'CaptureTests.pl',
	'RefundTests.pl',
	'GetPaymentTests.pl',
	'CallbackTests.pl',
);
my $formatterClassInput;
$options = GetOptions("output=s" => \$formatterClassInput);

my $formatterClass = TAP::Formatter::Console;

if($formatterClassInput eq "junit")
{
	$formatterClass = TAP::Formatter::JUnit;
}


my $harness = TAP::Harness->new( {
    verbosity => 0,
    formatter_class => $formatterClass,
 } );
$harness->runtests(@tests);