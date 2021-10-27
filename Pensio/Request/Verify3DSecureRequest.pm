package Pensio::Request::Verify3DSecureRequest;

use strict;
use warnings;
use Moose;

require Pensio::Request::AbstractPaymentRequest;
extends 'Pensio::Request::AbstractPaymentRequest';

has 'paRes' => (
    isa      => 'Str',
    is       => 'rw',
    required => 1,
);

sub parameters {
    my ($self) = @_;

    my $params = $self->Pensio::Request::AbstractPaymentRequest::parameters();

    $params->{transactionId} = $params->{transaction_id};

    delete $params->{transaction_id};

    $params->{"3DSecureRegular[MD]"}    = $params->{transactionId};
    $params->{"3DSecureRegular[paRes]"} = $self->paRes();

    return $params;
}

1;
