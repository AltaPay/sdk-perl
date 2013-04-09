package Pensio::Request::PaymentRequestConfig;

use strict;
use warnings;
use Moose;

has 'callbackForm' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackOk' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackFail' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackRedirect' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackOpen' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackNotification' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'callbackVerifyOrder' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

sub parameters {
	my ($self) = @_;

	my $params = {};
	
	$params->{'config[callback_form]'} = $self->callbackForm();
	$params->{'config[callback_ok]'} = $self->callbackOk();
	$params->{'config[callback_fail]'} = $self->callbackFail();
	$params->{'config[callback_redirect]'} = $self->callbackRedirect();
	$params->{'config[callback_open]'} = $self->callbackOpen();
	$params->{'config[callback_notification]'} = $self->callbackNotification();
	$params->{'config[callback_verify_order]'} = $self->callbackVerifyOrder();
	
	return $params;
}

1;