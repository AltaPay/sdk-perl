package Pensio::Response::PensioAbstractPaymentResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

use Pensio::Response::PensioAPIPayment;

has 'result' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
);

has 'merchant_error_message' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getMerchantErrorMessage',
);

has 'card_holder_error_message' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getCardHolderErrorMessage',
);

has 'card_holder_message_must_be_shown' => (
      is  => 'rw',
      isa => 'Maybe[Str]',
      reader => 'getCardHolderMessageMustBeShown',
);

has payments => (
    is => 'rw',
    isa => 'ArrayRef[Pensio::Response::PensioAPIPayment]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        addPayment  => 'push',
        getPayments => 'elements',
    },
);

sub BUILD
{
	my ($self, $xml) = @_;
	if(defined $xml->{Body}->{Result})
	{
		if(!(ref($xml->{Body}->{Result}) eq "HASH"))
		{
			$self->result($xml->{Body}->{Result});
		}
		else
		{
			$self->result('');
		}
	}
	if(defined $xml->{Body}->{Transactions})
	{
		my $transactions = $xml->{Body}->{Transactions}->{Transaction};
		my @payments = ( ref($transactions) eq 'ARRAY' ) ? @{$transactions} : ( $transactions ); 
		for my $Transaction ( @payments ) {
			$self->addPayment(new Pensio::Response::PensioAPIPayment($Transaction));
		}
	}
	if(defined $xml->{Body}->{MerchantErrorMessage})
	{
		$self->merchant_error_message($xml->{Body}->{MerchantErrorMessage});
	}
	if(defined $xml->{Body}->{CardHolderErrorMessage})
	{
		$self->card_holder_error_message($xml->{Body}->{CardHolderErrorMessage});
	}
	if(defined $xml->{Body}->{CardHolderMessageMustBeShown})
	{
		$self->card_holder_message_must_be_shown($xml->{Body}->{CardHolderMessageMustBeShown});
	}
	return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'Success';
}

sub wasDeclined
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'Failed';
}

sub wasErroneous
{
	my ($self) = @_;
    return $self->getErrorCode() != '0' || $self->result eq 'Error';
}

sub getPrimaryPayment
{
	my ($self) = @_;
	foreach my $payment ($self->getPayments())
	{
		return $payment;
	}
	return undef;
}

sub getLatestPayment
{
	my ($self) = @_;
	my @payments = $self->getPayments();
	if (@payments){
		return $payments[-1];
	}
	return undef;
}

1;
