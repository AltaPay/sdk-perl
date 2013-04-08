package Pensio::InitiatePaymentRequest;

use strict;
use warnings;
use Moose;

has 'amount' => (
	isa => 'Num', 
	is => 'rw',
	required => 1,
);

has 'orderId' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'terminal' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'currency' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'paymentSource' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
	default => sub { 'eCommerce' }
);

has 'cardnum' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'emonth' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'eyear' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);


#########################
#  Optional Parameters  #
#########################
has 'cvc' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'cardholderName' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'cardholderAddress' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'type' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'issueNumber' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'startMonth' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'startYear' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

#has 'transaction_info' => (
#	isa => 'Str', 
#	is => 'rw',
#	required => 0,
#);

has 'fraud_service' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
	default => sub { 'none' }
);

has 'customer_created_date' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'shipping_method' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
	default => sub { 'LowCost' },
);


sub parameters {
	my ($self) = @_;
	
	return {
		amount => $self->amount(),
		shop_orderid => $self->orderId(),
		terminal => $self->terminal(),
		currency => $self->currency(),
		payment_source => $self->paymentSource(),
		cardnum => $self->cardnum(),
		emonth => $self->emonth(),
		eyear => $self->eyear(),
		
		# Optional
		cvc => $self->cvc(),
		cardholderName => $self->cardholderName(),
		cardholderAddress => $self->cardholderAddress(),
		type => $self->type(),
		issueNumber => $self->issueNumber(),
		startMonth => $self->startMonth(),
		startYear => $self->startYear(),
		fraud_service => $self->fraud_service(),
		customer_created_date => $self->customer_created_date(),
		shipping_method => $self->shipping_method(),
		#transaction_info => $self->transaction_info(),
	};
}

1;
