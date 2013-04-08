package Pensio::GetPaymentRequest;

use strict;
use warnings;
use Moose;

require Pensio::AbstractPaymentRequest;
extends 'Pensio::AbstractPaymentRequest';

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::AbstractPaymentRequest::parameters();
	return $params;
}

1;
