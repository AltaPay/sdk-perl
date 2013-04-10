package Pensio::http::HTTPUtilRequest;
use Moose;
use Data::Dumper;
use Encode;
use URI::Escape;

has 'url' => (isa => 'Str', is => 'rw');
has 'params' => (isa => 'HashRef', is => 'rw');
has 'username' => (isa => 'Str', is => 'rw');
has 'password' => (isa => 'Str', is => 'rw');

sub urlencoded {
	my ($self) = @_;
	
	if(scalar(keys $self->params()) > 0)
	{
		my @params        = qw();
		foreach my $key (keys $self->params)
		{
			if(defined $self->params->{$key})
			{
				push(@params, $key."=".uri_escape($self->params->{$key}));
			}
		}
		return join('&', @params);
	}
	else
	{
		return "";
	}
}

1;