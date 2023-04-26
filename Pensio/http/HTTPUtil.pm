package Pensio::http::HTTPUtil;

use HTTP::Headers;
use HTTP::Request::Common;
use HTML::Entities;
use Encode;
use LWP::UserAgent;
use XML::Simple;
use Pensio::AltaPayVersion;

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;

    return $self;
}

sub _get_useragent {
    my ($self, %args) = @_;
    my $header = HTTP::Headers->new;

    my $agent = LWP::UserAgent->new(default_headers => $header,);

    #get user agent from Pensio::AltaPayVersion
    $agent->agent(Pensio::AltaPayVersion->new->user_agent());
    return $agent;
}

sub _parse_xml {
    my ($self, $xml) = @_;

    # We need to ensure that the string begins with a open angle bracket,
    # otherwise it gets treated as a filename.
    if ($xml =~ /^</) {
        return XML::Simple::XMLin($xml);
    }
    return 0;
}

sub _parse_http_response {
    my ($self, %args) = @_;
    my $response = $args{response};
    my $xml_as_hash;
    my $throw_error = '';    # throw error /after/ we've logged the message!

    if ($response && $response->is_success) {
        $xml_as_hash = $self->_parse_xml($response->content);

        if (!$xml_as_hash) {
            $throw_error = "Response from Pensio was successful but could not parse XML. Got back: " . $response->content;
        }
    } else {
        my $e = '';
        $e = $response->content if $response;
        $throw_error = "Response from Pensio: " . $e . ", status_line = " . $response->status_line;
    }

    if ($throw_error) {
        die $throw_error;
    }

    return $xml_as_hash;
}

sub _POST {
    my ($self, $request, $is_get_request) = @_;

    my $agent   = $self->_get_useragent();
    $is_get_request = $is_get_request ? $is_get_request : 0;
    my $req;
    if ($is_get_request == 0) {
        my $content = $request->urlencoded();
        $req = HTTP::Request->new(POST => $request->url);
        $req->content($content);
        $req->content_type("application/x-www-form-urlencoded");
    } else {
        my $url = $request->url;
        my $params = $request->params();
        if ($params) {
            $url = $url . '?' . join('&', map("$_=" . encode("utf8", $params->{$_}), keys %{$params}));
        }
        $req = HTTP::Request->new(GET => $url);
    }
    $req->header('x-altapay-client-version' => 'PERLSDK/' . $Pensio::AltaPayVersion::VERSION);
    $req->authorization_basic($request->username, $request->password);

    my $response = $agent->request($req);
    my $xml_as_hash = $self->_parse_http_response(response => $response);    # logs response too

    return $xml_as_hash;
}

1;
