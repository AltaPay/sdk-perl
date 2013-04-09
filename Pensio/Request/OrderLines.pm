package Pensio::Request::OrderLines;

use strict;
use warnings;
use Moose;
use Hash::Merge qw (merge);
use Data::Dumper;

use Pensio::Request::OrderLine;

has 'lines' => (
	isa => 'ArrayRef', 
	is => 'rw',
	required => 0,
	default => sub { [] },
);

sub add {
	my $self = shift;
	my $params = $self->BUILDARGS(@_);

	$params->{"key"} = scalar(@{$self->lines()});
	my $line = new Pensio::Request::OrderLine($params);
	
	push(@{$self->lines}, $line);
}

sub BUILD {
	my ($self, $xml) = @_;
	
	return $self;
}

sub parameters {
;
	my ($self) = @_;

	my $params = {};
	
	foreach my $line (@{$self->lines}) {
		
		$params = merge($params, $line->parameters());
	}
	
	return $params;
}

1;