package Pensio::Request::CustomerInfoAddress;

use strict;
use warnings;
use Moose;

has 'addressType' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has 'firstName' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'lastName' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'address' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'city' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'region' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'postalCode' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'country' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

sub parameters {
    my ($self) = @_;

    my $params = {};

    $params->{"customer_info[" . $self->addressType() . "_firstname]"} = $self->firstName();
    $params->{"customer_info[" . $self->addressType() . "_lastname]"}  = $self->lastName();
    $params->{"customer_info[" . $self->addressType() . "_address]"}   = $self->address();
    $params->{"customer_info[" . $self->addressType() . "_city]"}      = $self->city();
    $params->{"customer_info[" . $self->addressType() . "_region]"}    = $self->region();
    $params->{"customer_info[" . $self->addressType() . "_postal]"}    = $self->postalCode();
    $params->{"customer_info[" . $self->addressType() . "_country]"}   = $self->country();

    return $params;
}

1;