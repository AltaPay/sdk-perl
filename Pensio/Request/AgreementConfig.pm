package Pensio::Request::AgreementConfig;

use strict;
use warnings;
use Moose;
use Moose::Util::TypeConstraints;
use Hash::Merge qw (merge);
use MooseX::Types::Moose qw/ Str HashRef /;

has 'agreementId' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'agreementType' => (
	isa => enum([ qw[ recurring instalment unscheduled ] ]),
	is  => 'rw',
	required => 0,
);

has 'agreementUnscheduledType' => (
	isa => enum([ qw[ incremental resubmission delayedCharges reauthorisation noShow charge ] ]),
	is  => 'rw',
	required => 0,
);

has 'agreementExpiry' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'agreementFrequency' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'agreementNextChargeDate' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'agreementAdminUrl' => (
	isa => 'Str', 
	is => 'rw',
	required => 0,
);

has 'agreementRetentionPeriod' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
);

sub parameters {
	my ($self) = @_;

	my $params = {};

	$params->{"agreement[id]"} = $self->agreementId();
	$params->{"agreement[type]"} = $self->agreementType();
	$params->{"agreement[unscheduled_type]"} = $self->agreementUnscheduledType();
	$params->{"agreement[expiry]"} = $self->agreementExpiry();
	$params->{"agreement[frequency]"} = $self->agreementFrequency();
	$params->{"agreement[next_charge_date]"} = $self->agreementNextChargeDate();
	$params->{"agreement[admin_url]"} = $self->agreementAdminUrl();
	$params->{"agreement[retention_period]"}  = $self->agreementRetentionPeriod();

	return $params;
}

class_type 'Pensio::Request::AgreementConfig';

coerce 'Pensio::Request::AgreementConfig',
    => from HashRef,
    => via { new Pensio::Request::AgreementConfig( $_ ) };

1;
