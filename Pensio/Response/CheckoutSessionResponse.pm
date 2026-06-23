package Pensio::Response::CheckoutSessionResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'sessionId' => (
	is     => 'rw',
	isa    => 'Maybe[Str]',
	reader => 'getSessionId',
);

has 'sessionStatus' => (
	is     => 'rw',
	isa    => 'Maybe[Str]',
	reader => 'getSessionStatus',
);

sub wasSuccessful
{
	my ($self) = @_;
	return $self->getErrorCode() == '0' && defined $self->getSessionId();
}

sub BUILD
{
	my ($self, $xml) = @_;
	if (defined $xml->{Body}->{Session}) {
		$self->sessionId($xml->{Body}->{Session}->{Id});
		$self->sessionStatus($xml->{Body}->{Session}->{Status});
	}
	return $self;
}

1;
