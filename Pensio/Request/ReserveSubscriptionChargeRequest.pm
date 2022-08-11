package Pensio::Request::ReserveSubscriptionChargeRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);

require Pensio::Request::AgreementBasedRequest;
extends 'Pensio::Request::AgreementBasedRequest';


sub BUILD
{
	my ($self, $xml) = @_;

	return $self;
}


sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AgreementBasedRequest::parameters();
	return $params;
}

1;
