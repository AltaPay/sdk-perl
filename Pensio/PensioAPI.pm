package Pensio::PensioAPI;

use strict;
use warnings;
use MooseX::Params::Validate;

use XML::Simple;
use HTTP::Request;
use LWP::UserAgent;
use Pensio::http::HTTPUtil;
use Pensio::Response::PensioLoginResponse;
use Pensio::Response::PensioGetPaymentResponse;
use Pensio::Response::PensioReleaseResponse;
use Pensio::Response::PensioCaptureResponse;
use Pensio::Response::PensioRefundResponse;
use Pensio::Response::PensioInitiatePaymentResponse;
use Pensio::Response::PensioCreatePaymentRequestResponse;
use Pensio::Response::PensioVerify3DSecureResponse;
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
	my ($self, $params) = @_;
    # Log only clean data
    my %clean_data = ();
    %{$clean_data{params}} = %{$params};    
    #my %clean_params = %{$params};

    if (defined $clean_data{params}->{cardnum}) {
        $clean_data{params}->{cardnum} = '************' . substr($clean_data{params}->{cardnum}, -4);
    }

	if(defined $clean_data{params}->{cvc}) {
		$clean_data{params}->{cvc} = '***';
	}
	
	return $clean_data{params};
}

sub _sendRequest {
	my ($self, $path, $params) = @_;
	my $url     = $self->{'_installation_url'} . $path;
	my $logId;
	my $response;
	
	if($self->{_logger})
	{
		$logId = $self->{_logger}->logRequest($url, $self->_mask_parameters($params));
	}
	
	my $request = Pensio::http::HTTPUtilRequest->new();
	$request->url($url);
	$request->params($params);
	$request->username($self->{_username});
	$request->password($self->{_password});
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

sub getPayment {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::GetPaymentRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/payments', $request->parameters());
	return new Pensio::Response::PensioGetPaymentResponse($xml_as_hash);
}

sub release {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::ReleaseRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/releaseReservation', $request->parameters());
	return new Pensio::Response::PensioReleaseResponse($xml_as_hash);
}

sub capture {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::CaptureRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/captureReservation', $request->parameters());
	return new Pensio::Response::PensioCaptureResponse($xml_as_hash);
}

sub updateOrder {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::UpdateOrderRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/updateOrder', $request->parameters());
	return new Pensio::Response::PensioCaptureResponse($xml_as_hash);
}

sub refund {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::RefundRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/refundCapturedReservation', $request->parameters());
	return new Pensio::Response::PensioRefundResponse($xml_as_hash);
}

sub initiatePayment {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::InitiatePaymentRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/processor/API/initiatePayment', $request->parameters());
	return new Pensio::Response::PensioInitiatePaymentResponse($xml_as_hash);
}

sub verify3DSecure {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::Verify3DSecureRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/processor/API/verify3dSecure', $request->parameters());
	return new Pensio::Response::PensioVerify3DSecureResponse($xml_as_hash);
}

sub createPaymentRequest {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::CreatePaymentRequestRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/createPaymentRequest', $request->parameters());
	return new Pensio::Response::PensioCreatePaymentRequestResponse($xml_as_hash);
}

sub reservation {
	my ($self, $request) = validated_list(
		\@_,
		request => { isa => 'Pensio::Request::ReservationRequest', required => 1 },
	);
	
	my $xml_as_hash  = $self->_sendRequest('/merchant/API/reservation', $request->parameters());
	return new Pensio::Response::ReservationResponse($xml_as_hash);
}

1;