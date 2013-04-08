package Pensio::Verify3DSecureRequest;

use strict;
use warnings;
use Moose;

require Pensio::AbstractPaymentRequest;
extends 'Pensio::AbstractPaymentRequest';

has 'paRes' => (
	isa => 'Str', 
	is => 'rw',
	required => 1,
);

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::AbstractPaymentRequest::parameters();
	$params->{transactionId} = $params->{transaction_id};
	delete $params->{transaction_id};
	$params->{paRes} = $self->paRes();
	return $params;
}

1;
