package ExampleStdoutLogger;
use Pensio::logging::PensioAbstractLogger;
use Data::Dumper;

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
	my ($self, $url, $params) = @_;
	my $logId = $self->{counter};
	my $paramsString = Dumper($params);
	$self->{counter} = $self->{counter} + 1;
	
	print '[',$logId,'] Request to: ', $url, ' with params: ', $paramsString , "\n";
	return $logId;
}

sub logResponse
{
	my ($self, $logId, $response) = @_;
	print '[',$logId,'] Response: ', Dumper($response) , "\n";
}


1;