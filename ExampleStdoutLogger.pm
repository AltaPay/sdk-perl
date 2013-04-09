package ExampleStdoutLogger;
use Pensio::logging::PensioAbstractLogger;
use Data::Dumper;
use Test::More;

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
	$self->{counter} = $self->{counter} + 1;
	
	my $cleanParams        = {};
	foreach my $key (keys $params)
	{
		if(defined $params->{$key})
		{
			$cleanParams->{$key} = $params->{$key};
		}
	}
	
	$Data::Dumper::Sortkeys = true;
	note('[',$logId,'] Request to: ', $url, ' with params: ', Dumper($cleanParams));
	return $logId;
}

sub logResponse
{
	my ($self, $logId, $response) = @_;
	note('[',$logId,'] Response: ', Dumper($response));
}


1;