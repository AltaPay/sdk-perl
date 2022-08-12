package Pensio::Response::CardWalletSessionResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'result' => (
	is  => 'rw',
	isa => 'Maybe[Str]',
);

has 'applePaySession' => (
	is  => 'rw',
	isa => 'Maybe[Str]',
);

sub wasSuccessful
{
	my ($self) = @_;
	return $self->getErrorCode() == '0' && $self->result eq 'Success';
}

sub BUILD
{
	my ($self, $xml) = @_;
	if(defined $xml->{Body}->{Result})
	{
		$self->result($xml->{Body}->{Result});
		$self->applePaySession($xml->{Body}->{ApplePaySession});
	}
	return $self;
}

1;
