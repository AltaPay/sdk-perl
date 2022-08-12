package Pensio::Request::CreatePaymentRequestRequest;

use strict;
use warnings;
use Moose;
use Pensio::Request::PaymentRequestConfig;
use Hash::Merge qw (merge);
use Moose::Util::TypeConstraints;
use Pensio::Request::AgreementConfig;

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
	isa => enum( [ qw(required disabled) ] ), 
	is => 'rw',
	required => 0
);

has 'config' => (
	isa => 'Pensio::Request::PaymentRequestConfig', 
	is => 'rw',
	required => 0
);

has 'agreementConfig' => (
	isa => 'Pensio::Request::AgreementConfig',
	is => 'rw',
	required => 0
);

has 'saleInvoiceNumber' => (
	isa => 'Str',
	is => 'rw',
	required => 0
);

has 'salesTax' => (
	isa => 'Num',
	is => 'rw',
	required => 0,
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->config(new Pensio::Request::PaymentRequestConfig());
	$self->agreementConfig(new Pensio::Request::AgreementConfig());

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
	$params->{"sale_invoice_number"} = $self->saleInvoiceNumber();
	$params->{sales_tax} = $self->salesTax();

	$params = merge($params, $self->config()->parameters());
	$params = merge($params, $self->agreementConfig()->parameters());

	return $params;
}


1;
