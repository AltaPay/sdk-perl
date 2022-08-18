package Pensio::Request::SetupSubscriptionRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);
use Moose::Util::TypeConstraints;
use Pensio::Request::AgreementConfig;

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

sub BUILD
{
	my ($self, $xml) = @_;
	$self->agreementConfig(new Pensio::Request::AgreementConfig());
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
	$params = merge($params, $self->agreementConfig()->parameters());
	
	return $params;
}


1;
