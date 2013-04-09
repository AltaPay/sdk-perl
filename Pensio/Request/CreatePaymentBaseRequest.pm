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
		
		# Optional
		type => $self->type(),
		fraud_service => $self->fraud_service(),
		customer_created_date => $self->customer_created_date(),
		shipping_method => $self->shipping_method(),
		#transaction_info => $self->transaction_info(),
	};
}


1;