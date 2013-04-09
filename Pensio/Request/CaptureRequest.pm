package Pensio::Request::CaptureRequest;

use strict;
use warnings;
use Moose;

use Pensio::Request::OrderLines;

use Hash::Merge qw (merge);

require Pensio::Request::AmountBasedPaymentRequest;
extends 'Pensio::Request::AmountBasedPaymentRequest';

has 'reconciliationIdentifier' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'invoiceNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'salesTax' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

has 'orderLines' => (
	isa => 'Pensio::Request::OrderLines', 
	is => 'rw',
	required => 0
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->orderLines(new Pensio::Request::OrderLines());
	
	return $self;
}


sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AbstractPaymentRequest::parameters();
	$params->{reconciliation_identifier} = $self->reconciliationIdentifier();
	$params->{invoice_number} = $self->invoiceNumber();
	$params->{sales_tax} = $self->salesTax();
	
	$params = merge($params, $self->orderLines()->parameters());
	
	return $params;
}

1;
