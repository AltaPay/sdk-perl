package Pensio::Request::CreateInvoiceReservationRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);
use Moose::Util::TypeConstraints;

require Pensio::Request::CreatePaymentBaseRequest;
extends 'Pensio::Request::CreatePaymentBaseRequest';

#########################
#  Optional Parameters  #
#########################

has 'accountNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'bankCode' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'paymentSource' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'organisationNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'personalIdentifyNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0
);

has 'birthDate' => (
	isa => 'Str', # YYYY-MM-DD 
	is => 'rw',
	required => 0
);


sub BUILD
{
	my ($self, $xml) = @_;
	
	return $self;
}

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();

	$params->{"accountNumber"} = $self->accountNumber();
	$params->{"bankCode"} = $self->bankCode();
	$params->{"payment_source"} = $self->paymentSource();
	$params->{"organisationNumber"} = $self->organisationNumber();
	$params->{"personalIdentifyNumber"} = $self->personalIdentifyNumber();
	$params->{"birthDate"} = $self->birthDate();
	
	return $params;
}


1;
