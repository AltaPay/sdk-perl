#!/usr/bin/perl

use TAP::Harness;
$|++;

my @tests = (
	'InitiatePaymentExample.pl',
	'CaptureExample.pl',
);


my $harness = TAP::Harness->new( {
    verbosity => 0,
 } );
$harness->runtests(@tests);