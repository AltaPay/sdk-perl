package Pensio::Response::PensioCaptureResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'result' => (
      is  => 'rw',
      isa => 'Str',
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
	my ($self) = shift;
    return $self->getErrorCode() == '0' && $self->result eq 'OK';
}

1;
