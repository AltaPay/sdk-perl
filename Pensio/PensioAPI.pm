package Pensio::PensioAPI;

use strict;
no strict 'refs';
use XML::Simple;
use HTTP::Request;
use LWP::UserAgent;
use Pensio::http::HTTPUtil;
use Pensio::Response::PensioLoginResponse;
use Pensio::http::HTTPUtilRequest;


sub new {
    my $class = shift;
    my $self = {
        _installation_url => shift,
        _username         => shift,
        _password         => shift,
        _useragent        => 'PensioPerlClientAPI-1.0.0',
        _logger           => undef,
        _http_util        => new Pensio::http::HTTPUtil(),
    };
    bless $self, $class;
    return $self;
}

sub setLogger {
    my ($self, $logger) = @_;
    $self->{'_logger'} = $logger;
}


sub _mask_parameters
{
	my ($self, %params) = @_;
    # Log only clean data
    my $clean_params = %params;

    if (defined $clean_params->{cardnum}) {
        $clean_params->{cardnum} = '************' . substr($clean_params->{cardnum}, -4);
    }

	if(defined $clean_params->{cvc}) {
		$clean_params->{cvc} = '***';
	}
	
	return $clean_params;
}

sub _sendRequest {
	my ($self, $path, %params) = @_;
	my $url     = $self->{'_installation_url'} . $path;
	my $logId;
	my $response;
	if($self->{_logger})
	{
		$logId = $self->{_logger}->logRequest($url, $self->_mask_parameters(%params));
	}
	
	my $request = Pensio::http::HTTPUtilRequest->new();
	$request->_url($url);
	$request->_params(%params);
	$request->_username($self->{_username});
	$request->_password($self->{_password});
	$response = $self->{'_http_util'}->_POST($request);  # will throw error if problem;
	if($self->{_logger})
	{
		$self->{_logger}->logResponse($logId, $response);
	}
	return $response;
}


sub login {
	my ($self) = @_;
	
    my $xml_as_hash  = $self->_sendRequest('/merchant/API/login', {});
	return new Pensio::Response::PensioLoginResponse($xml_as_hash);
}

1;