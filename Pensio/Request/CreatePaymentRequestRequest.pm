package Pensio::Request::CreatePaymentRequestRequest;

use strict;
use warnings;
use Moose;
use Pensio::Request::PaymentRequestConfig;
use Pensio::Request::CustomerInfo;
use Pensio::Request::OrderLines;
use Hash::Merge qw (merge);

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

has 'organisationNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'accountOffer' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'config' => (
	isa => 'Pensio::Request::PaymentRequestConfig', 
	is => 'rw',
	required => 0
);

has 'customerInfo' => (
	isa => 'Pensio::Request::CustomerInfo', 
	is => 'rw',
	required => 0
);

has 'orderLines' => (
	isa => 'Pensio::Request::OrderLines', 
	is => 'rw',
	required => 0
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->config(new Pensio::Request::PaymentRequestConfig());
	$self->customerInfo(new Pensio::Request::CustomerInfo());
	$self->orderLines(new Pensio::Request::OrderLines());
	
	return $self;
}

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();

	$params->{"language"} = $self->language();
	$params->{"account_offer"} = $self->accountOffer();
	$params->{"organisation_number"} = $self->organisationNumber();
	$params->{"cookie"} = $self->cookie();
	$params->{"sale_reconciliation_identifier"} = $self->saleReconciliationIdentifier();
	$params->{"ccToken"} = $self->creditCardToken();
	
	$params = merge($params, $self->config()->parameters());
	
	$params = merge($params, $self->customerInfo()->parameters());
	
	$params = merge($params, $self->orderLines()->parameters());
	
	return $params;
}


1;
