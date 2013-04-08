package Pensio::AbstractPaymentRequest;

use strict;
use warnings;
use Moose;

has 'paymentId' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);

sub parameters {
	my ($self) = @_;
	
	return {
		'transaction_id'=>$self->paymentId()
	};
}

1;
