package Pensio::Request::OrderLine;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Hash::Merge qw (merge);
use MooseX::Types::Moose qw/ Str HashRef /;


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

has 'taxAmount' => (
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
	isa => enum([qw(shipment handling item refund)]), 
	is => 'rw',
	required => 0,
);

has 'imageUrl' => (
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
	$params->{"orderLines[".$self->key()."][unitPrice]"} = $self->unitPrice();
	$params->{"orderLines[".$self->key()."][taxPercent]"} = $self->taxPercent();
	$params->{"orderLines[".$self->key()."][taxAmount]"} = $self->taxAmount();
	$params->{"orderLines[".$self->key()."][unitCode]"} = $self->unitCode();
	$params->{"orderLines[".$self->key()."][discount]"} = $self->discount();
	$params->{"orderLines[".$self->key()."][goodsType]"} = $self->goodsType();
	$params->{"orderLines[".$self->key()."][imageUrl]"} = $self->imageUrl();
	
	return $params;
}

class_type 'Pensio::Request::OrderLine';

coerce 'Pensio::Request::OrderLine',
    => from HashRef,
    => via { new Pensio::Request::OrderLine( $_ ) };



1;