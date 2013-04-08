package Pensio::Response::PensioCaptureResponse;
use Pensio::Response::PensioAbstractResponse;

@ISA = qw(Pensio::Response::PensioAbstractResponse);
@EXPORT = qw(wasSuccessful);

sub new
{
	my ($class, $xml) = @_;
	my $self  = Pensio::Response::PensioAbstractResponse->new();
	$self->{'result'} = $xml->{Body}->{Result} if $self->getErrorCode() == 0;
	bless $self, $class;
	return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
	return $self->getErrorCode() == '0' && $self->{result} == 'OK';
}

1;
