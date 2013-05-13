package Pensio::Request::CreatePaymentBaseRequest;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Hash::Merge qw (merge);
use Pensio::Request::OrderLines;

use Pensio::Request::CustomerInfo;


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

has 'authType' => (
	isa => enum([ qw(payment paymentAndCapture subscription subscriptionAndCharge verifyCard) ]), 
	is => 'rw',
	required => 0,
);

#has 'transactionInfo' => (
#	isa => 'Str', 
#	is => 'rw',
#	required => 0,
#);

has 'fraudService' => (
	isa => enum([ qw[ none maxmind test red ] ]), 
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
	isa => enum([ qw(LowCost DesignatedByCustomer International Military NextDay Other StorePickup TwoDayService ThreeDayService) ]), 
	is => 'rw',
	required => 0,
);

has 'customerInfo' => (
	isa => 'Pensio::Request::CustomerInfo', 
	is => 'rw',
	required => 0,
	lazy_build => 1,
	coerce => 1,
);

has 'orderLines' => (
	isa => 'Pensio::Request::OrderLines', 
	is => 'rw',
	required => 0,
	lazy_build => 1,
	coerce => 1,
);

sub _build_orderLines {
	my ($self) = @_;
	return new Pensio::Request::OrderLines();
}

sub _build_customerInfo {
	my ($self) = @_;
	return new Pensio::Request::CustomerInfo();
}

sub BUILD
{
	my ($self, $xml) = @_;
	return $self;
}

sub parameters {
	my ($self) = @_;
	
	my $params = {
		amount => $self->amount(),
		shop_orderid => $self->orderId(),
		terminal => $self->terminal(),
		currency => $self->currency(),
		
		# Optional
		type => $self->authType(),
		fraud_service => $self->fraudService(),
		customer_created_date => $self->customerCreatedDate(),
		shipping_method => $self->shippingMethod(),
		#transaction_info => $self->transactionInfo(),
		
	};
	$params = merge($params, $self->customerInfo()->parameters());
	$params = merge($params, $self->orderLines()->parameters());
	return $params;
}


1;
