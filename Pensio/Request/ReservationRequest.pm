package Pensio::Request::ReservationRequest;

use strict;
use warnings;
use Moose;
use Pensio::Request::PaymentRequestConfig;
use Hash::Merge qw (merge);
use Moose::Util::TypeConstraints;

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

has 'paymentSource' => (
	isa => enum( [ qw(eCommerce mobi moto mail_order telephone_order) ] ), 
	is => 'rw',
	required => 0
);

has 'surcharge' => (
	isa => 'Str', 
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

	$params->{"credit_card_token"} = $self->creditCardToken();
	$params->{"cardnum"} = $self->pan();
	$params->{"emonth"} = $self->expiryMonth();
	$params->{"eyear"} = $self->expiryYear();
	$params->{"cvc"} = $self->cvc();
	$params->{"payment_source"} = $self->paymentSource();
	$params->{"surcharge"} = $self->surcharge();
	
	$params = merge($params, $self->config()->parameters());
	
	return $params;
}


1;
