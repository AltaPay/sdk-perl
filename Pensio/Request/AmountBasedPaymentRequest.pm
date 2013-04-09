package Pensio::Request::AmountBasedPaymentRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::AbstractPaymentRequest;
extends 'Pensio::Request::AbstractPaymentRequest';

has 'amount' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AbstractPaymentRequest::parameters();
	$params->{amount} = $self->amount();
	return $params;
}

1;