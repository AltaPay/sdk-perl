package Pensio::Response::PensioLoginResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'result' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
);

sub BUILD
{
	my ($self, $xml) = @_;
	if(defined $xml->{Body}->{Result})
	{
		$self->result($xml->{Body}->{Result});
	}
    return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'OK';
}

1;
