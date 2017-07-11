package Pensio::Request::UpdateOrderRequest;

use strict;
use warnings;
use Moose;

use Pensio::Request::OrderLines;

use Hash::Merge qw (merge);

has 'paymentId' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

has 'orderLines' => (
	isa => 'Pensio::Request::OrderLines', 
	is => 'rw',
	required => 1
);

sub BUILD
{
	my ($self, $xml) = @_;
	
	$self->orderLines(new Pensio::Request::OrderLines());
	
	return $self;
}


sub parameters {
	
	
	my ($self) = @_;
	
	my $params = {};
	
	$params->{payment_id} = $self->paymentId();
	
	$params = merge($params, $self->orderLines()->parameters());
	
	return $params;
}

1;
