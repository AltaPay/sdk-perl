package Pensio::Request::AgreementBasedRequest;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Pensio::Request::OrderLines;
use Hash::Merge qw (merge);

has 'agreementId' => (
    isa => 'Str',
    is => 'rw',
    required => 1,
);

has 'agreementUnscheduledType' => (
    isa => enum([ qw[ incremental resubmission delayedCharges reauthorisation noShow charge ] ]),
    is  => 'rw',
    required => 0,
);

has 'agreementRetryDays' => (
    isa      => 'Num',
    is       => 'rw',
    required => 0,
);

has 'amount' => (
    isa      => 'Num',
    is       => 'rw',
    required => 0,
);

has 'surchargeAmount' => (
    isa      => 'Num',
    is       => 'rw',
    required => 0,
);

has 'transactionInfo' => (
    isa => 'HashRef',
    is => 'rw',
    required => 0,
);

has 'orderLines' => (
    isa => 'Pensio::Request::OrderLines',
    is => 'rw',
    required => 0,
    lazy_build => 1,
    coerce => 1,
);

sub _build_orderLines {
    my ($self) = @_;
    return new Pensio::Request::OrderLines();
}

sub BUILD
{
    my ($self, $xml) = @_;
    return $self;
}

sub parameters {
    my ($self) = @_;
    my $params = {};

    $params->{"agreement[id]"} = $self->agreementId();
    $params->{"agreement[unscheduled_type]"} = $self->agreementUnscheduledType();
    $params->{"agreement[retry_days]"} = $self->agreementRetryDays();
    $params->{amount} = $self->amount();
    $params->{surcharge_amount} = $self->surchargeAmount();

    if (defined $self->transactionInfo())
    {
        while ((my $key, my $value) = each %{$self->transactionInfo()})
        {
            $params->{"transaction_info[".$key."]"} = $value;
        }
    }

    $params = merge($params, $self->orderLines()->parameters());

    return $params;
}

1;