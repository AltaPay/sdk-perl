package Pensio::Request::CreatePaymentBaseRequest;

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

#########################
#  Optional Parameters  #
#########################

has 'type' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

#has 'transactionInfo' => (
#	isa => 'Str', 
#	is => 'rw',
#	required => 0,
#);

has 'fraudService' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
	default => sub { 'none' }
);

has 'customerCreatedDate' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'shippingMethod' => (
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
		
		# Optional
		type => $self->type(),
		fraud_service => $self->fraudService(),
		customer_created_date => $self->customerCreatedDate(),
		shipping_method => $self->shippingMethod(),
		#transaction_info => $self->transactionInfo(),
	};
}


1;