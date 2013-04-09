package Pensio::Request::CreatePaymentRequestRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::CreatePaymentBaseRequest;
extends 'Pensio::Request::CreatePaymentBaseRequest';

#########################
#  Optional Parameters  #
#########################


sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();
	$params->{amount} = $self->amount();
	return $params;
}


1;
