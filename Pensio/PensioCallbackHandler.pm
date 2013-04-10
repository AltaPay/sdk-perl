package Pensio::PensioCallbackHandler;

use strict;
use warnings;
use Moose;
use Pensio::Response::PensioPaymentResponse;
use XML::Simple;
use Data::Dumper;

sub BUILD {
	my ($self, $xml) = @_;
	
	return $self;
}

sub parseXmlResponse {
	my ($self, $xml) = @_;
	
	my $xmlHash = $self->parseXml($xml);
	$self->verifyXml($xmlHash);
	
	# This is not a perfect way of figuring out what kind of response would be appropriate
	# At some point we should have a more direct link between something in the header
	# and the way the result should be interpreted.
	
	my $authType = $xmlHash->{Body}->{Transactions}->{Transaction}->{AuthType};
	
	if(!($authType =~ m/^(payment|paymentAndCapture|recurring|subscription|verifyCard)$/)) {
		die("Unsupported 'authType': (".$authType.")");
	}
	
	return return new Pensio::Response::PensioPaymentResponse($xmlHash);
}

sub verifyXml {
	my ($self, $xml) = @_;
	
	if(!defined $xml->{Header})
	{
		die("No <Header> in callback xml");
	}
	if(!defined $xml->{Header}->{ErrorCode})
	{
		die("No <ErrorCode> in Header of response");
	}
	if(!defined $xml->{Body})
	{
		die("No <Body> in response");
	}
	if(!defined $xml->{Body}->{Transactions})
	{
		my $error = $self->getBodyMerchantErrorMessage($xml);
		die("No <Transactions> in <Body> of response: ".$error);
	}
	if(!defined $xml->{Body}->{Transactions}->{Transaction})
	{
		my $error = $self->getBodyMerchantErrorMessage($xml);
		die("No <Transaction> in <Transactions> of response: ".$error);
	}
	if(!defined $xml->{Body}->{Transactions}->{Transaction}->{AuthType})
	{
		my $error = $self->getBodyMerchantErrorMessage($xml);
		die("No <AuthType> in <Transaction> of response: ".$error);
	}
}

sub getBodyMerchantErrorMessage {
	my ($self, $xml) = @_;

	if(isset($xml->{Body}->{MerchantErrorMessage}))
	{
		return $xml->{Body}->{MerchantErrorMessage};
	}
	return "";
}

sub parseXml {
	my ($self, $xml) = @_;

	if(ref $xml eq "XML::Simple") {
		return $xml;
	}

	if ($xml =~ /^</) {
		return XML::Simple::XMLin($xml);
	}
	
	die("Could not parse xml");
}


1;