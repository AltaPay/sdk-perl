package Pensio::Request::CheckoutSessionRequest;

use strict;
use warnings;
use Moose;

has 'terminals' => (
	isa      => 'ArrayRef[Str]',
	is       => 'rw',
	required => 1,
);

has 'shopOrderId' => (
	isa      => 'Str',
	is       => 'rw',
	required => 1,
);

has 'amount' => (
	isa      => 'Num',
	is       => 'rw',
	required => 1,
);

has 'currency' => (
	isa      => 'Str',
	is       => 'rw',
	required => 1,
);

has 'terminal' => (
	isa      => 'Str',
	is       => 'rw',
	required => 0,
);

has 'sessionId' => (
	isa      => 'Str',
	is       => 'rw',
	required => 0,
);

sub BUILD
{
	my ($self, $xml) = @_;
	return $self;
}

sub parameters {
	my ($self) = @_;

	my $params = {
		shop_orderid => $self->shopOrderId(),
		amount       => $self->amount(),
		currency     => $self->currency(),
		terminal     => $self->terminal(),
		session_id   => $self->sessionId(),
	};

	my @terminals = @{$self->terminals()};
	for my $i (0 .. $#terminals) {
		$params->{"terminals[$i]"} = $terminals[$i];
	}

	return $params;
}

1;
