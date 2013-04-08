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
	};
}

1;
