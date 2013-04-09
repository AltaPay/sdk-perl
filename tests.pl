#!/usr/bin/perl

use TAP::Harness;
use TAP::Formatter::JUnit;
$|++;

my @tests = (
	'InitiatePaymentExample.pl',
	'ReleaseExample.pl',
	'CaptureExample.pl',
);


my $harness = TAP::Harness->new( {
    verbosity => 0,
    formatter_class => TAP::Formatter::JUnit,
 } );
$harness->runtests(@tests);