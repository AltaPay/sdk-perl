package Pensio::http::HTTPUtilRequest;
use Moose;
use Data::Dumper;
use Encode;

has 'url' => (isa => 'Any', is => 'rw');
has 'params' => (isa => 'HashRef', is => 'rw');
has 'username' => (isa => 'Any', is => 'rw');
has 'password' => (isa => 'Any', is => 'rw');

sub urlencoded {
	my ($self) = @_;
	
	if(scalar(keys $self->params()) > 0)
	{
		my $params        = $self->params;
		return join('&', map("$_=" . encode("utf8", $params->{$_}), keys %{$params}) );
	}
	else
	{
		return "";
	}
}

1;