package Pensio::Request::ReleaseRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::AbstractPaymentRequest;
extends 'Pensio::Request::AbstractPaymentRequest';

sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AbstractPaymentRequest::parameters();
	return $params;
}

1;
