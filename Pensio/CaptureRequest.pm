package Pensio::CaptureRequest;
use Moose;
use Data::Dumper;

has 'amount' => (isa => 'Any', is => 'rw');
has 'paymentId' => (isa => 'Any', is => 'rw');

sub parameters {
	my ($self) = @_;
	
	return {
		'amount'=>$self->amount(),
		'transaction_id'=>$self->paymentId()
	};
}

1;
