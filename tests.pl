#!/usr/bin/perl

use TAP::Harness;
$|++;

my @tests = ('InitiatePaymentExample.pl',);


my $harness = TAP::Harness->new( {
    verbosity => 1,
 } );
$harness->runtests(@tests);