package Pensio::Request::RefundRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::AmountBasedPaymentRequest;
extends 'Pensio::Request::AmountBasedPaymentRequest';

has 'reconciliationIdentifier' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AmountBasedPaymentRequest::parameters();
	$params->{reconciliation_identifier} = $self->reconciliationIdentifier();
	
	return $params;
}

1;
