package Pensio::Request::CardWalletAuthorizeRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);

require Pensio::Request::CreatePaymentRequestRequest;
extends 'Pensio::Request::CreatePaymentRequestRequest';

has 'providerData' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);


sub BUILD
{
	my ($self, $xml) = @_;

	return $self;
}


sub parameters {
	my ($self) = @_;

	my $params = $self->Pensio::Request::CreatePaymentRequestRequest::parameters();
	$params->{"provider_data"} = $self->providerData();

	return $params;
}

1;
