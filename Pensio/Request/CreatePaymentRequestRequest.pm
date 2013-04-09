package Pensio::Request::CreatePaymentRequestRequest;

use strict;
use warnings;
use Moose;
use Pensio::Request::PaymentRequestConfig;

require Pensio::Request::CreatePaymentBaseRequest;
extends 'Pensio::Request::CreatePaymentBaseRequest';

#########################
#  Optional Parameters  #
#########################

has 'language' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'creditCardToken' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'saleReconciliationIdentifier' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'cookie' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'config' => (
	isa => 'Pensio::Request::PaymentRequestConfig', 
	is => 'rw',
	required => 0
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->config(new Pensio::Request::PaymentRequestConfig());
	
	return $self;
}

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();
	
	return $params;
}


1;
