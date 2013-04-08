package Pensio::CaptureRequest;

use strict;
use warnings;
use Moose;

has 'amount' => (
	isa => 'Num', 
	is => 'rw',
	required => 1,
);
has 'paymentId' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);

sub parameters {
	my ($self) = @_;
	
	return {
		'amount'=>$self->amount(),
		'transaction_id'=>$self->paymentId()
	};
}

1;
