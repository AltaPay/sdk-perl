package Pensio::Request::CustomerInfo;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Hash::Merge qw (merge);
use MooseX::Types::Moose qw/ Str HashRef /;

use Pensio::Request::CustomerInfoAddress;

has 'email' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'username' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'customerPhone' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'bankName' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'bankPhone' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'gender' => (
    isa => enum([ qw[ F M male female ] ]),
    is  => 'rw',
    required => 0,
);

has 'ipAddress' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

has 'clientSessionId' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

has 'clientAcceptLanguage' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

has 'clientUserAgent' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

has 'clientForwardedIp' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

has 'billingAddress' => (
	isa => 'Pensio::Request::CustomerInfoAddress', 
	is => 'rw',
	required => 0,
	lazy_build => 1,
);

sub _build_billingAddress {
    my ($self) = @_;
    return new Pensio::Request::CustomerInfoAddress(addressType => "billing");
}

has 'shippingAddress' => (
	isa => 'Pensio::Request::CustomerInfoAddress', 
	is => 'rw',
	required => 0,
	lazy_build => 1,
);

sub _build_shippingAddress {
    my ($self) = @_;
    return new Pensio::Request::CustomerInfoAddress(addressType => "shipping");
}

sub parameters {
	my ($self) = @_;

	my $params = {};
	
	$params->{"customer_info[email]"} = $self->email();
	$params->{"customer_info[username]"} = $self->username();
	$params->{"customer_info[customer_phone]"} = $self->customerPhone();
	$params->{"customer_info[bank_name]"} = $self->bankName();
	$params->{"customer_info[bank_phone]"} = $self->bankPhone();
	$params->{"customer_info[gender]"}  = $self->gender();
	$params->{"customer_info[client_ip]"}  = $self->ipAddress();
	$params->{"customer_info[client_session_id]"}  = $self->clientSessionId();
	$params->{"customer_info[client_accept_language]"}  = $self->clientAcceptLanguage();
	$params->{"customer_info[client_user_agent]"}  = $self->clientUserAgent();
	$params->{"customer_info[client_forwarded_ip]"}  = $self->clientForwardedIp();	
	
	$params = merge($params, $self->billingAddress()->parameters());
	
	$params = merge($params, $self->shippingAddress()->parameters());
	
	return $params;
}

class_type 'Pensio::Request::CustomerInfo';

coerce 'Pensio::Request::CustomerInfo',
    => from HashRef,
    => via { new Pensio::Request::CustomerInfo( $_ ) };

1;
