package Pensio::Response::PensioAbstractPaymentResponse;

use strict;
use warnings;
use Moose;

require Pensio::Response::PensioAbstractResponse;
extends 'Pensio::Response::PensioAbstractResponse';

use Pensio::Response::PensioAPIPayment;

has 'result' => (
      is  => 'rw',
      isa => 'Str',
);

has 'merchant_error_message' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getMerchantErrorMessage',
);

has payments => (
    is => 'rw',
    isa => 'ArrayRef[Pensio::Response::PensioAPIPayment]',
    default => sub { [] },
    traits  => ['Array'],
    handles => {
        add_payment  => 'push',
        get_payments => 'elements',
    },
);

sub BUILD
{
	my ($self, $xml) = @_;
	if(defined $xml->{Body}->{Result})
	{
		$self->result($xml->{Body}->{Result});
	}
	if(defined $xml->{Body}->{Transactions})
	{
		for my $Transaction ( $xml->{Body}->{Transactions}->{Transaction} ) {
			$self->add_payment(new Pensio::Response::PensioAPIPayment($Transaction));
		}
	}
	if(defined $xml->{Body}->{MerchantErrorMessage})
	{
		$self->merchant_error_message($xml->{Body}->{MerchantErrorMessage});
	}
	return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    return $self->getErrorCode() == '0' && $self->result eq 'Success';
}

1;
