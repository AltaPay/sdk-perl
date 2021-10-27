package Pensio::Request::InitiatePaymentRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::CreatePaymentBaseRequest;
extends 'Pensio::Request::CreatePaymentBaseRequest';

has 'paymentSource' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
    default  => sub { 'eCommerce' }
);

has 'cardnum' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has 'emonth' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

has 'eyear' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

#########################
#  Optional Parameters  #
#########################
has 'cvc' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'cardholderName' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'cardholderAddress' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'issueNumber' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'startMonth' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

has 'startYear' => (
    isa      => 'Str',
    is       => 'rw',
    required => 0,
);

sub parameters {
    my ($self) = @_;

    my $params = $self->Pensio::Request::CreatePaymentBaseRequest::parameters();
    $params->{amount} = $self->amount();

    $params->{payment_source} = $self->paymentSource();
    $params->{cardnum}        = $self->cardnum();
    $params->{emonth}         = $self->emonth();
    $params->{eyear}          = $self->eyear();

    $params->{cvc}               = $self->cvc();
    $params->{cardholderName}    = $self->cardholderName();
    $params->{cardholderAddress} = $self->cardholderAddress();
    $params->{issueNumber}       = $self->issueNumber();
    $params->{startMonth}        = $self->startMonth();
    $params->{startYear}         = $self->startYear();

    return $params;
}

1;
