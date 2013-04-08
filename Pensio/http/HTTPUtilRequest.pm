package Pensio::http::HTTPUtilRequest;


sub new {
	$class = shift;
	
	$self = {};
	
	bless $self, $class;
	
	return $self;
}

sub _url {
	my ($self, $url) = @_;
	
	if(defined $url)
	{
		$self->{url} = $url;
	}
	
	return $self->{url};
}

sub _params {
	my ($self, $params) = @_;
	
	if(defined $params)
	{
		$self->{params} = $params;
	}
	
	return $self->{params};
}

sub _username {
	my ($self, $username) = @_;
	
	if(defined $username)
	{
		$self->{username} = $username;
	}
	
	return $self->{username};
}

sub _password {
	my ($self, $password) = @_;
	
	if(defined $password)
	{
		$self->{password} = $password;
	}
	
	return $self->{password};
}

sub urlencoded {
	my ($self) = @_;

	return join('&', map("$_=" . encode("utf8", $self->{params}->{$_}), keys %{$self->{params}}) );
}


1;