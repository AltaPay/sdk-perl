package Pensio::Response::ReservationResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractPaymentResponse;
extends 'Pensio::Response::PensioAbstractPaymentResponse';



sub BUILD
{
	my ($self, $xml) = @_;
	return $self;
}

1;
