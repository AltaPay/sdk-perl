package Pensio::Response::PensioCreatePaymentRequestResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'url' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getUrl',
      required => 0,
);

has 'result' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
);

sub BUILD
{
	my ($self, $xml) = @_;
	$self->url($xml->{Body}->{Url});
	$self->result($xml->{Body}->{Result});
	return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'Success';
}

1;
