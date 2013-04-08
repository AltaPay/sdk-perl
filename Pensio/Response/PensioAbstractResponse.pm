package Pensio::Response::PensioAbstractResponse;

use strict;
use warnings;
use Moose;

has 'date' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getDate',
);

has 'path' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getPath',
);

has 'errorCode' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getErrorCode',
);

has 'errorMessage' => (
      is  => 'rw',
      isa => 'Str',
      reader => 'getErrorMessage',
);

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
sub BUILD
{
    my ($self, $xml) = @_;
    
	$self->date($xml->{Header}->{Date});
	$self->path($xml->{Header}->{Path});
	$self->errorCode($xml->{Header}->{ErrorCode});
	if(defined $xml->{Header}->{ErrorMessage})
	{
		$self->errorMessage("".$xml->{Header}->{ErrorMessage});
	}
    return $self;
}

sub wasSuccessful
{
	my ($self) = @_;
    die "wasSuccessful() must be overridden by a subclass of __PACKAGE__";
}

1;