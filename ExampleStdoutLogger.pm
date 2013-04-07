package ExampleStdoutLogger;
use Pensio::logging::PensioAbstractLogger;

@ISA = qw(Pensio::logging::PensioAbstractLogger);


sub new
{
	my ($class) = @_;
	my $self = Pensio::logging::PensioAbstractLogger->new();
	$self->{counter} = 10000;
	
    bless $self, $class;
    return $self;
}

sub logRequest
{
	my ($self, $url, %params) = @_;
	my $logId = $self->{counter};
	$self->{counter} = $self->{counter} + 1;
	
	print '[',$logId,'] Request to: ', $url, ' with params: ', %params , "\n";
	return $logId;
}

sub logResponse
{
	my ($self, $logId, $response) = @_;
	print '[',$logId,'] Response: ', $response , "\n";
}


1;