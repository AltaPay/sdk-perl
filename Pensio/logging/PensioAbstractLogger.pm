package Pensio::logging::PensioAbstractLogger;

sub new
{
	my ($class) = @_;
	my $self = {};
    bless $self, $class;
    return $self;
}

sub logRequest
{
	my ($self, $url, %params) = @_;
	die "logRequest(url, params) must be overridden by a subclass of __PACKAGE__";
}

sub logResponse
{
	my ($self, $logId, $response) = @_;
	die "logResponse(logId, response) must be overridden by a subclass of __PACKAGE__";
}

1;