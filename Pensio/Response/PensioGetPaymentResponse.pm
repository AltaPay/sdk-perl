package Pensio::Response::PensioGetPaymentResponse;

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

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && scalar($self->getPayments()) == 1;
}

1;
