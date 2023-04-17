package Pensio::Response::ReserveSubscriptionChargeResponse;

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

sub BUILD
{
	my ($self, $xml) = @_;
	if($self->wasRedirect){
		$self->redirect_url($xml->{Body}->{RedirectResponse}->{Url});
	}
	return $self;
}

sub wasRedirect
{
	my ($self) = @_;
	return $self->getErrorCode() == '0' && $self->result eq 'Redirect';
}

1;
