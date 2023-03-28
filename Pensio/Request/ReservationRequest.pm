package Pensio::Request::ReservationRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);
use Moose::Util::TypeConstraints;
use Pensio::Request::AgreementConfig;
use Pensio::Request::PaymentRequestConfig;

require Pensio::Request::CreatePaymentBaseRequest;
extends 'Pensio::Request::CreatePaymentBaseRequest';

#########################
#  Optional Parameters  #
#########################

has 'creditCardToken' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'pan' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'expiryMonth' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'expiryYear' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'cvc' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'surcharge' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'agreementConfig' => (
	isa => 'Pensio::Request::AgreementConfig',
	is => 'rw',
	required => 0
);

has 'salesTax' => (
	isa => 'Num',
	is => 'rw',
	required => 0,
);

has 'cookie' => (
	isa => 'Str',
	is => 'rw',
	required => 0
);

has 'saleInvoiceNumber' => (
	isa => 'Str',
	is => 'rw',
	required => 0
);

has 'saleReconciliationIdentifier' => (
	isa => 'Str',
	is => 'rw',
	required => 0
);

has 'language' => (
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
	$self->agreementConfig(new Pensio::Request::AgreementConfig());
	$self->config(new Pensio::Request::PaymentRequestConfig());
	return $self;
}

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();

	$params->{"credit_card_token"} = $self->creditCardToken();
	$params->{"cardnum"} = $self->pan();
	$params->{"emonth"} = $self->expiryMonth();
	$params->{"eyear"} = $self->expiryYear();
	$params->{"cvc"} = $self->cvc();
	$params->{"surcharge"} = $self->surcharge();
	$params->{sales_tax} = $self->salesTax();
	$params->{"cookie"} = $self->cookie();
	$params->{"sale_invoice_number"} = $self->saleInvoiceNumber();
	$params->{"sale_reconciliation_identifier"} = $self->saleReconciliationIdentifier();
	$params->{"language"} = $self->language();
	$params = merge($params, $self->config()->parameters());
	$params = merge($params, $self->agreementConfig()->parameters());
	
	return $params;
}


1;
