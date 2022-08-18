package Pensio::Request::CardWalletSessionRequest;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);

has 'terminal' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);

has 'validationUrl' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);

has 'domain' => (
	isa => 'Str',
	is => 'rw',
	required => 1,
);



sub BUILD
{
	my ($self, $xml) = @_;

	return $self;
}


sub parameters {
	my ($self) = @_;

	my $params =  {
		terminal => $self->terminal(),
		validationUrl => $self->validationUrl(),
		domain => $self->domain(),
	};

	return $params;
}

1;
