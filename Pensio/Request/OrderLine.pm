package Pensio::Request::OrderLine;

use strict;
use warnings;
use Moose;

has 'key' => (
	isa => 'Int', 
	is => 'rw',
	required => 1,
);

has 'description' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'itemId' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'quantity' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

has 'taxPercent' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

has 'unitCode' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'unitPrice' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

has 'discount' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

has 'goodsType' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

sub parameters {
	my ($self) = @_;

	my $params = {};
	
	$params->{"orderLines[".$self->key()."][description]"} = $self->description();
	$params->{"orderLines[".$self->key()."][itemId]"} = $self->itemId();
	$params->{"orderLines[".$self->key()."][quantity]"} = $self->quantity();
	$params->{"orderLines[".$self->key()."][taxPercent]"} = $self->taxPercent();
	$params->{"orderLines[".$self->key()."][unitCode]"} = $self->unitCode();
	$params->{"orderLines[".$self->key()."][unitPrice]"} = $self->unitPrice();
	$params->{"orderLines[".$self->key()."][discount]"} = $self->discount();
	$params->{"orderLines[".$self->key()."][goodsType]"} = $self->goodsType();
	
	return $params;
}


1;