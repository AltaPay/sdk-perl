package Pensio::Response::PensioAbstractResponse;

#/**
# * <APIResponse version="20110831">
# * 	<Header>
# * 		<Date>2011-08-29T23:48:32+02:00</Date>
# * 		<Path>API/xxx</Path>
# * 		<ErrorCode>0</ErrorCode>
# * 		<ErrorMessage/>
# * 	</Header>
# * 	<Body>
# * 		[.....]
# * 	</Body>
# * </APIResponse>
# */
sub new
{
	my ($class, $xml) = @_;
	$self = {
		#version      => (string)$xml['version'],
		date         => $xml->{Header}->{ErrorMessage},
		path         => $xml->{Header}->{Path},
		errorCode    => $xml->{Header}->{ErrorCode},
		errorMessage => $xml->{Header}->{ErrorMessage},
	};
    bless $self, $class;
    return $self;
}
	
sub getVersion
{
	my ($self) = @_;
	return $self->{'version'};
}
	
sub getDate
{
	my ($self) = @_;
	return $self->{'date'};
}

sub getPath
{
	my ($self) = @_;
	return $self->{'path'};
}

sub getErrorCode
{
	my ($self) = @_;
	return $self->{'errorCode'};
}

sub getErrorMessage
{
	my ($self) = @_;
	return $self->{'errorMessage'};
}

sub wasSuccessful
{
	my ($self) = @_;
    die "wasSuccessful() must be overridden by a subclass of __PACKAGE__";
}

1;