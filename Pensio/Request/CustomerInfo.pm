package Pensio::Request::CustomerInfo;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);

use Pensio::Request::CustomerInfoAddress;

has 'email' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'username' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'customerPhone' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'bankName' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'bankPhone' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'bankPhone' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'billingAddress' => (
	isa => 'Pensio::Request::CustomerInfoAddress', 
	is => 'rw',
	required => 0,
);

has 'shippingAddress' => (
	isa => 'Pensio::Request::CustomerInfoAddress', 
	is => 'rw',
	required => 0,
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->billingAddress(new Pensio::Request::CustomerInfoAddress(addressType => "billing"));
	$self->shippingAddress(new Pensio::Request::CustomerInfoAddress(addressType => "shipping"));

	return $self;
}

sub parameters {
	my ($self) = @_;

	my $params = {};
	
	$params->{"customer_info[email]"} = $self->email();
	$params->{"customer_info[username]"} = $self->username();
	$params->{"customer_info[customer_phone]"} = $self->customerPhone();
	$params->{"customer_info[bank_name]"} = $self->bankName();
	$params->{"customer_info[bank_phone]"} = $self->bankPhone();
	
	
	$params = merge($params, $self->billingAddress()->parameters());
	
	$params = merge($params, $self->shippingAddress()->parameters());
	
	return $params;
}


1;