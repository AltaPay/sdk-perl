package Pensio::Response::PensioInitiatePaymentResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractPaymentResponse;
extends 'Pensio::Response::PensioAbstractPaymentResponse';

has 'redirect_url' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getRedirectUrl',
      required => 0,
);

has 'pa_req' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getPaReq',
      required => 0,
);


sub BUILD
{
	my ($self, $xml) = @_;
	if($self->was3DSecure)
	{
		$self->redirect_url($xml->{Body}->{RedirectUrl});
		$self->pa_req($xml->{Body}->{PaReq});
	}
	return $self;
}

sub was3DSecure
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq '3dSecure';
}

1;
