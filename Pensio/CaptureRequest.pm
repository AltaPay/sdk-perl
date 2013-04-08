package Pensio::CaptureRequest;

use strict;
use warnings;
use Moose;

require Pensio::AbstractPaymentRequest;
extends 'Pensio::AbstractPaymentRequest';

has 'amount' => (
	isa => 'Num', 
	is => 'rw',
	required => 0,
);

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::AbstractPaymentRequest::parameters();
	$params->{amount} = $self->amount();
	return $params;
}

1;
