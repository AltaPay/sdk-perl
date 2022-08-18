package Pensio::Request::ChargeSubscriptionRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);

require Pensio::Request::AgreementBasedRequest;
extends 'Pensio::Request::AgreementBasedRequest';

has 'reconciliationIdentifier' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

sub BUILD
{
	my ($self, $xml) = @_;

	return $self;
}


sub parameters {
	my ($self) = @_;
	
	my $params = $self->Pensio::Request::AgreementBasedRequest::parameters();
	$params->{reconciliation_identifier} = $self->reconciliationIdentifier();

	return $params;
}

1;
