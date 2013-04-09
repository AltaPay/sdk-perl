package Pensio::Response::PensioCreatePaymentRequestResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

has 'url' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getUrl',
      required => 1,
);

sub BUILD
{
	my ($self, $xml) = @_;
	$self->url($xml->{Body}->{Url});
	return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'Success';
}

1;
