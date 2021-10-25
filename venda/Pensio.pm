package PaymentProvider::Pensio;
use Moose;
extends 'CardPaymentProvider';
with 'PaymentProvider::Interface';
with 'PaymentService::Utils::Logging';

our $VERSION = '0.0.1';

use TryCatch;
use MooseX::StrictConstructor;
use Moose::Util 'find_meta';
use DateTime::HiRes;
use File::Basename;
use Encode;
use HTTP::Headers;
use HTTP::Request::Common;
use HTML::Entities;
use LWP::UserAgent;
use XML::Simple;
use Digest::MD5;

use PaymentService;
use Payment::Constants;
use Payment::CurrencyTypes;
use PaymentService::PaymentResponse;
use PaymentService::PaymentResponse::Card;
use PaymentService::PaymentResponse::Bank;
use PaymentService::PaymentResponse::Redirect;
use PaymentService::Constants;
use PaymentProvider::Null::Constants;

use MooseX::Types::Moose qw/ Bool Str /;

use Data::Dumper;
use Sys::Hostname;

#has '+_capabilities'   => (default =>   CAN_AUTH    | CAN_SETTLE    | CAN_REFUND_OLD| CAN_REFUND_NEW | CAN_CANCEL     |
#                                        CAN_3DSECURE  | CAN_ELV_AUTH  | CAN_ELV_SETTLE | CAN_ELV_REFUND | CAN_SECURITY_INFO);
has '+_capabilities' => (default => CAN_AUTH | CAN_SETTLE | CAN_REFUND_OLD | CAN_CANCEL | CAN_3DSECURE);

has '+_payment_methods' => (default => CAN_VISA | CAN_MASTERCARD | CAN_DISCOVER | CAN_DELTA | CAN_SWITCHMAESTRO | CAN_SOLO | CAN_AMERICANEXPRESS | CAN_DINNERSCLUB | CAN_JCB | CAN_VISAELECTRON | CAN_DIRECTDEBIT);

has ['api_base_merchant_url', 'api_base_processor_url', 'redirect_base_url'] => (isa => Str, is => 'rw', required => 1);    # https://{yourshopname}.pensio.com/processor/API/
has 'terminal_default'  => (isa => Str, is => 'rw', required => 1);                                                         # terminals can be configured to use different payment methods (ELV, iDeal etc)
                                                                                                                            # Use different terminals for "3DSecure on", "3DSecure off"
has 'terminal_3dsecure' => (isa => Str, is => 'rw', required => 0);
has 'secret'            => (isa => Str, is => 'rw', required => 0);                                                         # credit card calls do not need a secret, redirects (URL generation) do.
has 'fraud_service'     => (isa => Str, is => 'rw', required => 1, default => 'none');                                      # examples: none, test, maxmind, red

=head1 NAME

PaymentProvider::Pensio

=head1 DESCRIPTION

Pensio is a Danish company that has many integrations to smaller regional payment methods.
For example iDEAL is an Internet payment method in the Netherlands, based on online banking.

=head1 MAGIC CARDS

There are many test cards and/or test amounts that do trigger different responses.
As of 2012-07-11 they can be found here:
https://testgateway.pensio.com/merchant.php/help/TestCases

=head1 ELV MAGIC ACCOUNTS

It seems Pensio use test amounts to trigger different responses:
As of 2012-07-11 they can be found here:
https://testgateway.pensio.com/merchant.php/help/TestCases


=head1 METHODS

=over

=cut

my $BASEDIR = dirname(__FILE__);

# profile attributes -
# must say coerce => 1 for any Bool attributes
has 'enabled' => (isa => Bool, is => 'rw', required => 1, coerce => 1, default => 1);

#has always_accept => (isa => Bool, is => 'rw', required => 1, coerce => 1);

sub name { "pensio" }

=pod

=item BUILD()

Put values from pensio.ini into the _config attribute hash

=cut

sub BUILD {
    my ($self) = @_;

    $self->_BUILD_YAML($BASEDIR, 'pensio.yml');
}

sub _scalar_value {
    my ($self, $value) = @_;

    if (ref($value) eq 'SCALAR') {
        return $value;
    } elsif (ref($value) eq 'HASH') {
        if (scalar(%{$value}) == 0) {
            return undef;
        } else {
            $self->logger->info("Can not get a scalar value for hash : " . Dumper($value));
        }
    }

}

# The dispatchable set of actions here.

=item _pensio_translate_error

Pensio does not have one single point to test for success/fail.
This rountine is a wrapper around PaymentProvider::_translate_error because of this.

They have different errors reported in different places. Other providers have one single
code that has a one single meaning.

NOTE: The FraudRecommendation attribute is not taken into account in this rountine.

=cut

sub _pensio_translate_error {
    my ($self, $xml_as_hash) = @_;
    my $pensio_error_code = $xml_as_hash->{Header}->{ErrorCode};
    my $reason = $self->_scalar_value($xml_as_hash->{Header}->{ErrorMessage}) || 'ok';
    $reason = $self->_scalar_value($xml_as_hash->{Body}->{MerchantErrorMessage}) || $reason;
    my ($error_code, $q) = ('no_error', 0);

    if ($pensio_error_code != 0) {
        ($error_code, $q) = $self->_translate_error($pensio_error_code);
    } else {

        # Exceptions: API/login && API/createPaymentRequest
        if (defined $xml_as_hash->{Header}->{Path}
            && !($xml_as_hash->{Header}->{Path} eq 'API/login' || $xml_as_hash->{Header}->{Path} eq 'API/createPaymentRequest'))
        {

            my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction};
            my $card_status = $transaction->{CardStatus};

            if ($card_status ne 'Valid') {
                ($error_code, $q) = $self->_translate_error($card_status);
            } else {
                my $tdsr = $transaction->{ThreeDSecureResult};

                if (defined($tdsr) && $tdsr eq 'Error ') {
                    ($error_code, $q) = $self->_translate_error('Error');
                }
            }
        }
    }

    $error_code = 'undefined' if !$error_code;

    return ($error_code, $q, $reason);
}

=item _parse_xml

B<Description>

A simple wrapper so we don't try to parse rubbish

B<Returns>

=over

=item a hash

If it went well, otherwise nothing

=back

=cut

sub _parse_xml {
    my ($self, $xml) = @_;

    # We need to ensure that the string begins with a open angle bracket,
    # otherwise it gets treated as a filename.
    if ($xml =~ /^</) {
        return XML::Simple::XMLin($xml);
    }

    return;
}

=item _get_user_agent_string

TO DO: Something similar in CBA.pm. Promote to PaymentProvider.pm ??

=cut

sub _get_user_agent_string {
    my $hostname = hostname();
    my $version  = $PaymentService::VERSION;
    my $release  = $PaymentService::RELEASE;

    return "venda_vps/$version-$release (Language=Perl; Host=$hostname) ";
}

sub _get_useragent {
    my ($self, %args) = @_;
    my $cn = $args{CN};

    $ENV{HTTPS_PROXY} = $self->_config->{proxy}->{https} || '';
    $ENV{HTTP_PROXY}  = $self->_config->{proxy}->{http}  || '';

    my $ssl_subject_cn = $self->_config->{ssl}->{SSL_Subject_CN};
    my $header         = HTTP::Headers->new;
    $header->header('If-SSL-Cert-Subject', 'CN=' . $ssl_subject_cn) if $ssl_subject_cn;

    my $agent = LWP::UserAgent->new(default_headers => $header,);

    $agent->agent(_get_user_agent_string);
    return $agent;
}

=item _parse_http_response

Do basic error checking and log the message received.
Will throw an error if it does not like what comes back.

=cut

sub _parse_http_response {
    my ($self, %args) = @_;
    my $response     = $args{response};
    my $request      = $args{request};         # here for information to put in log message only
    my $internal_ref = $args{internal_ref};    # here for information to put in log message only
    my $transaction  = 1;                      # XML returned had a <transaction> element
    my $xml_as_hash;
    my $success     = 1;
    my $throw_error = '';                      # throw error /after/ we've logged the message!

    if ($response && $response->is_success) {
        $xml_as_hash = $self->_parse_xml($response->content);

        if ($xml_as_hash) {
            if (defined $xml_as_hash->{Header}->{ErrorCode} && $xml_as_hash->{Header}->{ErrorCode}) {
                $success = 0;
            }

            # Exception: API/login
            if (defined $xml_as_hash->{Header}->{Path} && $xml_as_hash->{Header}->{Path} eq 'API/login') {
                $transaction = 0;
            }

            # Exception: API/createPaymentRequest
            if (defined $xml_as_hash->{Header}->{Path} && $xml_as_hash->{Header}->{Path} eq 'API/createPaymentRequest') {
                $transaction = 0;
            }

            # Test for "normal" XML that contains <Transactions><Transaction>
            if ($transaction) {
                my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction} if defined $xml_as_hash->{Body}->{Transactions}->{Transaction};

                if (!$transaction) {
                    $success     = 0;
                    $throw_error = "Did not get back standard XML from Pensio, got: " . $response->content;
                }
            }
        } else {
            $success     = 0;
            $throw_error = "Response from Pensio was successful but could not parse XML. Got back: " . $response->content;
        }
    } else {
        $success = 0;
        my $e = '';
        $e = $response->content if $response;
        $throw_error = "Response from Pensio: " . $e . ", status_line = " . $response->status_line;
    }

    my ($orderID, $profile, $entprs);
    $profile = $request->profile if defined $request;
    $entprs  = $request->entprs  if defined $request;

    eval { $orderID = $request->orderID if defined $request };

    $self->_log_message(
        direction    => 'from_provider',
        orderID      => $orderID,
        internal_ref => $internal_ref,
        data         => $response->content,
        success      => $success,
        profile      => $profile,
        enterprise   => $entprs
    );

    if ($throw_error) {
        die $throw_error;
    }

    return $xml_as_hash;
}

sub _GET {
    my ($self, %args) = @_;
    my $url            = $args{url};
    my $params         = $args{params};
    my $no_transaction = $args{no_transaction};

    if ($params) {
        $url = $url . '?' . join('&', map("$_=" . encode("utf8", $params->{$_}), keys %{$params}));
    }

    my $agent = $self->_get_useragent();
    my $req = HTTP::Request->new(GET => $url);
    $req->authorization_basic($self->username, $self->password);

    my $response = $agent->request($req);

    my $xml_as_hash = $self->_parse_http_response(response => $response, no_transaction => $no_transaction);    # This will throw error if response is bas

    return $xml_as_hash;
}

sub _POST {
    my ($self, %args) = @_;
    my $url          = $args{url};
    my $params       = $args{params};
    my $internal_ref = $args{internal_ref};
    my $request      = $args{request};
    my $orderID;

    eval { $orderID = $request->orderID };    # Message may not have this set

    my $content = join('&', map("$_=" . encode("utf8", $params->{$_}), keys %{$params}));
    my $agent   = $self->_get_useragent();
    my $req     = HTTP::Request->new(POST => $url);

    $req->content_type("application/x-www-form-urlencoded");
    $req->content($content);
    $req->authorization_basic($self->username, $self->password);

    # Log only clean data
    my %clean_data = (url => $url);
    %{$clean_data{params}} = %{$params};

    if (defined $clean_data{params}->{cardnum}) {
        $clean_data{params}->{cardnum} = '************' . substr($clean_data{params}->{cardnum}, -4);
    }

    $clean_data{params}->{cvc} = '***' if defined $clean_data{params}->{cvc};

    $self->_log_message(
        direction    => 'to_provider',
        internal_ref => $internal_ref,
        orderID      => $orderID,
        data         => \%clean_data,
        success      => 1,
        profile      => $request->profile,
        enterprise   => $request->entprs
    );

    # Send actual message. _parse_http_response() will log the message after parsing the XML
    #

    my $response = $agent->request($req);
    my $xml_as_hash = $self->_parse_http_response(response => $response, request => $request, internal_ref => $internal_ref);    # logs response too

    return $xml_as_hash;
}

sub _handle_error_xml {
    my ($self, %args) = @_;
    my $request     = $args{request};
    my $xml_as_hash = $args{xml_as_hash};

    $self->logger->info("_handle_error_xml(): got back " . Dumper($xml_as_hash));

    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);

    return PaymentService::PaymentResponse::Base->new(
        error_code => $error_code,
        reason     => $reason,
        status     => VENDA_FAIL,
        time       => DateTime::HiRes->now,
        amount     => $request->amount,
        currency   => $request->currency,
    );
}

sub _test_connect {
    my ($self) = @_;
    my $test_url = $self->api_base_merchant_url . 'login';
    $self->_GET(url => $test_url);

}

=item _is_good_card_status

Values for CardStatus can be  Expired|SoonExpired|Valid|NoCreditCard

Quoting Pensio:

[CardStatus] Gives an indication wether a card is expired or is about to
expire. “Expired” is returned for expired credit cards, 
“SoonExpired” for cards that will expire in the next 3 
months and “Valid” for everything else. If no creditcard has 
been set on the payment yet, it will be “NoCreditCard”

=cut

sub _is_good_card_status {
    my ($self, $card_status) = @_;

    if ($card_status eq 'Valid' || $card_status eq 'SoonExpired') {
        return 1;
    }

    return 0;
}

=item _set_fraud_args

Add in fraud parameters into the hash reference passed in.
If the "redirect" flag is set then the params will be used in a URL and a checksum needs to be calculated and added.

=cut

sub _set_fraud_args {
    my ($self, %args) = @_;
    my $request     = $args{request};
    my $hash        = $args{hash};
    my $is_redirect = $args{is_redirect} || 0;
    my $address     = $request->address;

    # Mandatory fields
    $hash->{'customer_info[billing_city]'}    = $address->city;
    $hash->{'customer_info[billing_region]'}  = $address->county;
    $hash->{'customer_info[billing_postal]'}  = $address->postalCode;
    $hash->{'customer_info[billing_country]'} = $address->countryISO;

    # Optional fields
    $hash->{'customer_info[email]'}             = encode_utf8($address->email);
    $hash->{'customer_info[customer_phone]'}    = encode_utf8($address->phoneNumber) if $address->phoneNumber;
    $hash->{'customer_info[billing_firstname]'} = encode_utf8($address->firstName);
    $hash->{'customer_info[billing_lastname]'}  = encode_utf8($address->lastName);
    $hash->{'fraud_service'}                    = $self->fraud_service || 'none';                                # values might be none, test, maxmind or red. See FraudService enum type

    # If you send fraud detection params there is a minimum set we must provide in a "all or nothing" kinda way
    # BUT if the params will be used in a URL a user clicks on then the IP address is not required and if included
    # causes an error message :(
    if (!$is_redirect) {
        if ($address->ip && $address->city && $address->county && $address->postalCode && $address->countryISO) {
            $hash->{'customer_info[client_ip]'} = $address->ip;
        } else {
            die PaymentService::Message::Error->new(
                error      => 'Address for customer does not have all the fields required for a redirect to Pensio: ' . 'IP = ' . $address->ip . ', city = ' . $address->city . ', county = ' . $address->county . ', postalcode = ' . $address->postalCode . ', countryISO = ' . $address->countryISO,
                error_code => 'internal_error',
            );
        }
    } else {

        # Create checksum with "secret" so Pensio can tell if customer has tampered with the fields
        if (!$self->secret) {
            die PaymentService::Message::Error->new(
                error      => 'Fraud parameters with a redirect MUST have the "secret" set in the Pensio profile otherwise the checksum can not be created!',
                error_code => 'internal_error',
            );
        }

        if (!(keys %{$hash})) {
            die PaymentService::Message::Error->new(
                error      => 'No fraud parameters with a redirect. Was the address created correctly? (ip, city, county, postalCode & countryISO)',
                error_code => 'internal_error',
            );
        }

        my %simple_hash;

        foreach my $key (%{$hash}) {
            next if $key !~ /^customer_info/;
            my ($field) = ($key =~ /\[(.+)\]/);
            $simple_hash{$field} = $hash->{$key};
        }

        $simple_hash{secret} = $self->secret;
        my @array_of_strings;

        foreach my $key (sort keys %simple_hash) {
            push @array_of_strings, encode_utf8($key . '=' . $simple_hash{$key});
        }

        my $string = join(',', @array_of_strings);
        my $d = Digest::MD5->new;
        $d->add($string);
        my $generated_digest = $d->hexdigest;    # Call this once, calling it a second time seems to get a different answer

        $hash->{'customer_info[checksum]'} = $generated_digest;
    }

    return;
}

=item _build_initiatePayment_params

Parameter "payment_source" that gets sent to Penso "affects the bank fee's and the risk of chargebacks".
It can be one of these values:

  eCommerce  - customer present on website
  mobi       - mobile
  moto       - MO/TO. Basically customer not present

=cut

sub _build_initiatePayment_params {
    my ($self,                   $request) = @_;
    my ($threedsecure_is_needed, $error)   = $self->_should_3dsecure_auth($request);

    die $error if $error;

    my $payment_source = 'eCommerce';    # See POD above for what this means

    if ($request->cnp == 1) {
        $payment_source = 'moto';
    }

    my $card         = $request->payment_details;
    my $expiry_month = substr($card->expiry, 0, 2);
    my $expiry_year  = '20' . substr($card->expiry, 2, 2);

    my $currency_code = Payment::CurrencyTypes::get_numeric_currency_code_from_letter($request->currency);    # 978 = EUR, 826 = GBP etc
    my $terminal      = $self->terminal_default;
    $terminal = $self->terminal_3dsecure if $threedsecure_is_needed;

    my $address = $request->address;
    my $name    = encode_utf8($address->firstName . ' ' . $address->lastName);
    my @addr_values;

    foreach my $value ($address->addressLine1, $address->addressLine2, $address->city, $address->county, $address->country, $address->postalCode) {
        push @addr_values, $value || '';                                                                      # this loop just gets around any undef warnings to STDERR
    }

    my $free_form_address = encode_utf8(join(' ', @addr_values));

    my %optional_args;

    if ($card->start) {
        ($optional_args{startMonth}, $optional_args{startYear}) = ($card->start =~ /(\d\d)(\d\d)/);
    }

    # Fraud detection parameters are only mandatory if fraud detection is enabled for the terminal
    $self->_set_fraud_args(request => $request, hash => \%optional_args);

    # Build params that will be POSTed
    #
    my %params = (
        shop_orderid      => $request->orderID,
        terminal          => $terminal,             # string. The terminal you want to get payments for – detault is to show payments for all terminals.
        amount            => $request->amount,      # float. For a recurring payment the amount is the maximum amount for each installment.
        currency          => $currency_code,        # integer. 3 digit currency code. See ISO­4217 standard.
        payment_source    => $payment_source,
        cardnum           => $card->card_number,    # [0­9]{11.19}
        emonth            => $expiry_month,         # [0­9]{1.2}   Expiry month on the card.
        eyear             => $expiry_year,          # [0­9]{4}     Expiry year on the card.
                                                    # below are the optional params
        cvc               => $card->cv2,
        cardholderName    => $name,
        cardholderAddress => $free_form_address,
        %optional_args
    );

    return %params;
}

=item _authorise_card()

B<Description>

Create an authorisation on a credit/debit card.

The option settle_up_front is not supported by Pensio in the way we'd like it to be.
There is an argument, type, that can be set in the call reservationOfFixedAmountMOTO to
"paymentAndCapture" i.e. when the card holder is not present.
Because of this is it simpler to let the app use its own business logic than implement an edge case of
checking cnp = 1 AND settle_up_front = 1.


=cut

sub _authorise_card {
    my ($self, $request) = @_;

    if ($request->settle_up_front) {
        return PaymentService::Message::Error->new(
            error      => 'Pensio does not support settle up front (auth and settle in one step)',
            error_code => 'not_implemented',
        );
    }

    my $auth_url     = $self->api_base_processor_url . 'initiatePayment';
    my %params       = $self->_build_initiatePayment_params($request);
    my $internal_ref = $request->internal_ref ? $request->internal_ref : $self->_generate_internal_ref_from_orderID($request->orderID);

    my $xml_as_hash = $self->_POST(url => $auth_url, params => \%params, internal_ref => $internal_ref, request => $request);    # will throw error if problem

    $self->logger->debug("AuthRequest got an xml hash back of : " . Dumper($xml_as_hash));

    # Handle Pensio's response
    #
    my $now         = DateTime::HiRes->now;
    my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction};
    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);    # Result = Success, Failed or Error. It is not comprehensive :)
    my $response;

    if ($self->_is_good_card_status($transaction->{CardStatus})) {
        my %extra_opts = ();

        my $status           = VENDA_OK;
        my $amount           = $transaction->{ReservedAmount} || $transaction->{CapturedAmount};
        my $url              = '';
        my $pareq            = '';
        my $three_d_possible = 0;

        if ($xml_as_hash->{Body}->{Result} eq '3dSecure') {
            $url              = $xml_as_hash->{Body}->{RedirectUrl};
            $pareq            = $xml_as_hash->{Body}->{PaReq};
            $status           = VENDA_REDIRECT;
            $three_d_possible = 1;
        }

        if (defined($transaction->{FraudRecommendation}) && $transaction->{FraudRecommendation} ne 'Accept') {
            $reason = $transaction->{FraudExplanation} || 'FraudRiskScore too high';
            $reason .= '. FraudRiskScore = ' . $transaction->{FraudRiskScore};
            $status     = VENDA_FAIL;
            $error_code = 'suspected_fraud';
        }

        $response = PaymentService::PaymentResponse::Card->new(
            internal_ref             => $internal_ref,
            payment_provider_ref     => $transaction->{TransactionId},
            payment_provider_token   => $transaction->{CreditCardToken},          # might only be used for logging? pmooney 2012-04-17
            reason                   => $reason,
            status                   => $status,
            error_code               => $error_code,
            time                     => $now,
            amount                   => $amount,
            currency                 => $request->currency,
            'q'                      => $q,
            card_scheme              => $request->payment_details->card_scheme,
            issuer                   => '',
            country                  => '',                                       # TO DO: Not sure ever returned
            payment_provider_url     => $url,
            payment_provider_request => $pareq,

            third_party_check_is_possible => $three_d_possible,                   # if the terminal is not 3DS enabled we'll never know if it is possible

            %extra_opts,
        );
    } else {
        $response = PaymentService::PaymentResponse::Base->new(
            reason     => $transaction->{CardStatus},
            status     => VENDA_FAIL,
            error_code => $error_code,
            time       => $now,
            amount     => $request->amount,
            currency   => $request->currency,
        );
    }

    return $response;
}

sub _authorise_card_3DSecure {
    my ($self, $request) = @_;

    if (!($request->payment_provider_ref)) {
        return PaymentService::Message::Error->new(
            error      => 'For 3DSecure, Pensio requires the AuthRequest->payment_provider_ref to be set with the response from the first AuthRequest',
            error_code => 'undefined',
        );
    }

    my $verify_url = $self->api_base_processor_url . 'verify3dSecure';

    # Build params that will be POSTed
    #
    my %params = (
        transactionId => $request->payment_provider_ref,
        paRes         => $request->payment_provider_data->{PaRes}->[0],
    );

    $self->logger->debug("_authorise_card_3DSecure(): params = " . Dumper(\%params));    # TO DO : remove this debug line, its overkill

    my $internal_ref = $request->internal_ref ? $request->internal_ref : $self->_generate_internal_ref_from_orderID($request->orderID);

    my $xml_as_hash = $self->_POST(url => $verify_url, params => \%params, internal_ref => $internal_ref, request => $request);    # will throw error if problem

    $self->logger->debug("_authorise_card_3DSecure() got an xml hash back of : " . Dumper($xml_as_hash));

    # Handle Pensio's response
    #
    my $status      = VENDA_OK;
    my $card_scheme = '';
    my $token       = '';
    my $amount      = $request->amount;
    my $currency    = $request->currency;

    my $transaction_ref = '';
    my $transaction     = $xml_as_hash->{Body}->{Transactions}->{Transaction};

    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);
    my $response;

    if ($xml_as_hash->{Header}->{ErrorCode} != 0) {
        $status = VENDA_FAIL;
        $reason = $xml_as_hash->{Header}->{ErrorMessage};
    } else {
        $transaction_ref = $transaction->{TransactionId};
        $amount = $transaction->{ReservedAmount} || $transaction->{CapturedAmount};
        my $currency_code = $transaction->{MerchantCurrency};
        $currency = Payment::CurrencyTypes::get_letter_currency_code_from_number($currency_code);
        $token    = $transaction->{CreditCardToken};

        if ($self->_is_good_card_status($transaction->{CardStatus})) {
            if ($transaction->{ThreeDSecureResult} ne 'Successful') {

                # Work out the best "reason" to return why it failed.
                $status = VENDA_FAIL;
                $reason = "Failed 3DSecure transaction: ThreeDSecureResult = " . $transaction->{ThreeDSecureResult} . ", CardStatus = " . $transaction->{CardStatus};

                $reason = $xml_as_hash->{Body}->{MerchantErrorMessage} if defined($xml_as_hash->{Body}->{MerchantErrorMessage});
            } elsif ($request->currency ne $currency || $request->amount != $amount) {
                $status = VENDA_FAIL;
                $reason = "Failed 3DSecure transaction: amount/currency different to that requested. Got $amount, $currency" . ", expected " . $request->amount . ", " . $request->currency;
                $self->logger->info($reason);
            }
        } else {
            $status = VENDA_FAIL;
        }
    }

    if ($status == VENDA_FAIL) {
        $self->logger->debug("3DSecure failed for TransactionId " . $transaction_ref . " : " . $reason);
    }

    my $now = DateTime::HiRes->now;
    $response = PaymentService::PaymentResponse::Card->new(
        profile                => $request->profile,
        entprs                 => $request->entprs,
        card_scheme            => $card_scheme,
        issuer                 => '',                   # This could be very useful information if iDeal, ELV etc used.
        country                => '',                   # TO DO: Not sure ever returned
        internal_ref           => $internal_ref,
        payment_provider_ref   => $transaction_ref,
        payment_provider_token => $token,
        reason                 => $reason,
        error_code             => $error_code,
        status                 => $status,
        time                   => $now,
        amount                 => $request->amount,
        currency               => $request->currency,
        'q'                    => $q,
    );

    return $response;
}

=item _build_createPayment_params

Build a URL that calls Pensio via a HTTPS POST that returns a URL to redirect the user.
This is instead of the user click a URL with the same params in (plus our checksum) and stops
them trying to change the params.

=cut

sub _build_createPayment_params {
    my ($self, %args) = @_;
    my $request      = $args{request};
    my $internal_ref = $args{internal_ref};

    my $currency_code = Payment::CurrencyTypes::get_numeric_currency_code_from_letter($request->currency);    # 978 = EUR, 826 = GBP etc
    my $terminal      = $self->terminal_default;
    my $address       = $request->address;
    my $name          = encode_utf8($address->firstName . ' ' . $address->lastName);
    my @addr_values;

    foreach my $value ($address->addressLine1, $address->addressLine2, $address->city, $address->county, $address->country, $address->postalCode) {
        push @addr_values, $value || '';                                                                      # this loop just gets around any undef warnings to STDERR
    }

    my $free_form_address = encode_utf8(join(' ', @addr_values));

    my %optional_args;

    # Fraud detection parameters are only mandatory if fraud detection is enabled for the terminal
    $self->_set_fraud_args(request => $request, hash => \%optional_args);

    # Build params that will be POSTed
    #
    my %params = (
        shop_orderid => $request->orderID,
        terminal     => $terminal,           # string. The terminal you want to get payments for – detault is to show payments for all terminals.
        amount       => $request->amount,    # float. For a recurring payment the amount is the maximum amount for each installment.
        currency     => $currency_code,      # integer. 3 digit currency code. See ISO­4217 standard.
        %optional_args
    );

    return %params;
}

sub _authorise_redirect {
    my ($self, $request) = @_;

    $self->logger->debug("_authorise_redirect(): building params");

    my $currency_code = Payment::CurrencyTypes::get_numeric_currency_code_from_letter($request->currency);                                 # 978 = EUR, 826 = GBP etcq
    my $internal_ref  = $request->internal_ref ? $request->internal_ref : $self->_generate_internal_ref_from_orderID($request->orderID);
    my $create_url    = $self->api_base_merchant_url . 'createPaymentRequest';
    my %params        = $self->_build_createPayment_params(request => $request, internal_ref => $internal_ref);

    my %optional_args;
    $self->_set_fraud_args(request => $request, hash => \%optional_args, is_redirect => 1);

    %params = (
        %params,
        terminal     => $self->terminal_default,
        amount       => $request->amount,
        currency     => $currency_code,
        shop_orderid => $request->orderID,
        %optional_args,
    );

    $self->logger->debug("_authorise_redirect(): \$create_url = $create_url, \%params = " . Dumper(\%params));

    my $xml_as_hash = $self->_POST(url => $create_url, params => \%params, internal_ref => $internal_ref, request => $request);    # will throw error if problem

    $self->logger->debug("_authorise_redirect got an xml hash back of : " . Dumper($xml_as_hash));

    # Handle Pensio's response
    #
    my $now          = DateTime::HiRes->now;
    my $redirect_url = $xml_as_hash->{Body}->{Url};
    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);    # Result = Success, Failed or Error. It is not comprehensive :)

    if (!$redirect_url) {
        $self->logger->info("No URL returned from call to createPaymentRequest");
        return PaymentService::PaymentResponse::Base->new(
            internal_ref => $internal_ref,
            reason       => $reason,
            status       => VENDA_FAIL,
            error_code   => $error_code,
            time         => $now,
            amount       => $request->amount,
            currency     => $request->currency,
        );
    }

    return PaymentService::PaymentResponse::Redirect->new(
        url          => $redirect_url,
        internal_ref => $internal_ref,
        reason       => $reason,
        status       => VENDA_REDIRECT,
        error_code   => $error_code,
        time         => $now,
        amount       => $request->amount,
        currency     => $request->currency,
    );
}

=pod

=item PaymentService_Message_AuthRequest

B<Description>

Either:

Request authorisation to take money from a card.
If the 'payment_provider_response' attribute (the PaRes) is present then this is the second AuthRequest

Or:

Request for a redirection URL, kinda like 3DSecure.

Return a 

B<Params>

=over

=item C<PaymentService::Message::AuthRequest>

=back

B<Returns>

A PaymentService::PaymentResponse::Card on success,
A PaymentService::PaymentResponse::Base on fail

=cut

sub PaymentService_Message_AuthRequest {
    my ($self, $request) = @_;
    my $obj;
    my $action = '';

    try {
        if (   $request->payment_provider_data
            && $request->payment_provider_data->{PaRes})
        {
            # A previous AuthRequest has been done
            $action = 'verify paRes';
            $obj    = $self->_authorise_card_3DSecure($request);
        } else {
            if ($request->payment_details
                && ref($request->payment_details) eq 'Payment::PaymentDetails::Card')
            {
                $action = 'authorise a card payment';
                $obj    = $self->_authorise_card($request);
            } else {
                $action = 'authorise redirect';
                $obj    = $self->_authorise_redirect($request);
            }
        }
    }
    catch ($error) {
        if (ref($error)) {
            return $error;
        } else {
            return PaymentService::Message::Error->new(
                error      => "Caught an error when dealing with an AuthRequest to $action: '$error'",
                error_code => 'undefined',
            );
        }
    }

    return $obj;

}

sub _handle_call {
    my ($self, %args) = @_;
    my $url          = $args{url};
    my $params       = $args{params};
    my $type         = $args{type};
    my $request      = $args{request};
    my $internal_ref = $args{internal_ref};
    my ($xml_as_hash, $response);

    try {
        $xml_as_hash = $self->_POST(url => $url, params => $params, request => $request, internal_ref => $internal_ref);    # will throw error if problem
    }
    catch ($error) {
        if (ref($error)) {
            return $error;
        } else {
            $response = PaymentService::Message::Error->new(
                error      => "Pensio caught an error when dealing with an " . $type . "Request: '$error'",
                error_code => 'undefined',
            );
        }
    }

    return ($xml_as_hash, $response);
}

=pod

=item PaymentService_Message_SettleRequest()

B<Description>

Settle/capture an earlier authorisation request. This has to be a follow on from a previous authorisation.

B<Params>

=over

=item C<PaymentService::Message::SettleRequest>

=back

B<Returns>

A PaymentService::Message::Response which holds the C<result>, a PaymentService::PaymentResponse::Base


=cut

sub PaymentService_Message_SettleRequest {
    my ($self, $request) = @_;

    $self->logger->debug("SettleRequest. request = " . Dumper($request));
    my $settle_url = $self->api_base_merchant_url . 'captureReservation';

    $self->logger->debug("settle url = $settle_url");

    my %params = (
        transaction_id => $request->payment_provider_ref,

        # below are the optional params
        amount => $request->amount,

        #orderLines => '', # "an array of lines" - this will not be used by us, it is for "factoring"
        #reconciliation_i dentifier => '', #If you wish to define the reconciliation identifier used in the dentifier reconciliation csv files, you can choose to set it here.
        #invoice_number => # If you wish to decide what the invoice number is on a Gothia invoice, set it here
    );

    my ($xml_as_hash, $response) = $self->_handle_call(type => 'Settle', url => $settle_url, params => \%params, request => $request, internal_ref => $request->internal_ref);
    return $response if $response;

    $self->logger->debug("SettleRequest got an xml hash back of : " . Dumper($xml_as_hash));

    my $result = $xml_as_hash->{Body}->{Result} if defined $xml_as_hash->{Body}->{Result};
    my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction} if defined $xml_as_hash->{Body}->{Transactions}->{Transaction};
    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);
    my $status = VENDA_OK;

    if ($result eq 'Success' && $transaction) {
        if ($transaction->{TransactionStatus} ne 'captured') {
            $status = VENDA_FAIL;
            $reason .= " : TransactionStatus does not equal 'captured' it is actually '" . $transaction->{TransactionStatus} . "'";
            $self->logger->debug("TransactionStatus does not equal 'captured'");
        }

        $response = PaymentService::PaymentResponse::Base->new(
            internal_ref         => $request->internal_ref,
            payment_provider_ref => $transaction->{TransactionId},
            reason               => $reason,
            error_code           => $error_code,
            status               => $status,
            time                 => DateTime::HiRes->now,
            amount               => $request->amount,
            currency             => $request->currency,
        );
    } else {

        # We got something unexpected back
        $response = $self->_handle_error_xml(request => $request, xml_as_hash => $xml_as_hash);
    }

    $self->logger->debug("SettleRequest() returning: " . Dumper($response));

    return $response;
}

=pod

=item PaymentService_Message_RefundRequest()

B<Description>

Not all payments can be refunded, and some can be refunded multiple times, depending on 
the payment nature (CreditCard, E­Payment, BankPayment and iDEAL) and on the acquirer used.

B<Params>

=over

=item C<PaymentService::Message::RefundRequest>


=back

B<Returns>

A PaymentService::Message::Response which holds the C<result>, a PaymentService::PaymentResponse::Base


=cut

sub PaymentService_Message_RefundRequest {
    my ($self, $request) = @_;

    $self->logger->debug("RefundRequest request = " . Dumper($request));

    if (!$request->payment_provider_ref) {
        die PaymentService::Message::Error->new(
            error      => "When calling RefundRequest the payment_provider_ref for the previous transaction MUST be passed in",
            error_code => 'internal_error',
        );
    }

    my $refund_url = $self->api_base_merchant_url . 'refundCapturedReservation';

    my %params = (
        transaction_id => $request->payment_provider_ref,

        # below are the optional params
        amount => $request->amount,

        #reconciliation_identifier => '',
    );

    my ($xml_as_hash, $response) = $self->_handle_call(type => 'Refund', url => $refund_url, params => \%params, request => $request, internal_ref => $request->internal_ref);
    return $response if $response;

    $self->logger->debug("RefundRequest got an xml hash back of : " . Dumper($xml_as_hash));

    my $result = $xml_as_hash->{Body}->{Result} if defined $xml_as_hash->{Body}->{Result};
    my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction} if defined $xml_as_hash->{Body}->{Transactions}->{Transaction};
    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);
    my $status = VENDA_OK;

    if ($result eq 'Success' && $transaction) {
        if ($transaction->{TransactionStatus} ne 'refunded') {
            $status = VENDA_FAIL;
            $reason .= " : TransactionStatus does not equal 'refunded' it is actually '" . $transaction->{TransactionStatus} . "'";
            $self->logger->debug("TransactionStatus does not equal 'refunded'");
        }

        $response = PaymentService::PaymentResponse::Base->new(
            internal_ref         => $request->internal_ref,
            payment_provider_ref => $transaction->{TransactionId},
            reason               => $reason,
            error_code           => $error_code,
            status               => VENDA_OK,
            time                 => DateTime::HiRes->now,
            amount               => $request->amount,
            currency             => $request->currency,
        );
    } else {

        # We got something unexpected back
        $response = $self->_handle_error_xml(request => $request, xml_as_hash => $xml_as_hash);
    }

    $self->logger->debug("RefundRequest() returning: " . Dumper($response));

    return $response;
}

=pod

=item PaymentService_Message_CancelRequest()

B<Description>

Cancel/void an request earlier authorisation.

B<Params>

=over

=item C<PaymentService::Message::CancelRequest>

=back

B<Returns>

A PaymentService::Message::Response which holds the C<result>, a PaymentService::PaymentResponse::Base


=cut

sub PaymentService_Message_CancelRequest {
    my ($self, $request) = @_;
    $self->logger->debug("CancelRequest request = " . Dumper($request));

    my $cancel_url = $self->api_base_merchant_url . 'releaseReservation';

    my %params = (transaction_id => $request->payment_provider_ref,);

    my ($xml_as_hash, $response) = $self->_handle_call(type => 'Cancel', url => $cancel_url, params => \%params, request => $request, internal_ref => $request->internal_ref);
    return $response if $response;

    $self->logger->debug("CancelRequest got an xml hash back of : " . Dumper($xml_as_hash));

    my $result = $xml_as_hash->{Body}->{Result} if defined $xml_as_hash->{Body}->{Result};
    my $transaction = $xml_as_hash->{Body}->{Transactions}->{Transaction} if defined $xml_as_hash->{Body}->{Transactions}->{Transaction};
    my ($error_code, $q, $reason) = $self->_pensio_translate_error($xml_as_hash);
    my $status = VENDA_OK;

    if ($result eq 'Success' && $transaction) {
        if ($transaction->{TransactionStatus} ne 'released') {
            $status = VENDA_FAIL;
            $reason .= " : TransactionStatus does not equal 'released', it is '" . $transaction->{TransactionStatus} . "'";
            $self->logger->debug("TransactionStatus does not equal 'released' , it is " . $transaction->{TransactionStatus} . "'");
        }

        $response = PaymentService::PaymentResponse::Base->new(
            internal_ref         => $request->internal_ref,
            payment_provider_ref => $transaction->{TransactionId},
            reason               => $reason,
            error_code           => $error_code,
            status               => $status,
            ,
            time     => DateTime::HiRes->now,
            amount   => $request->amount,
            currency => $request->currency,
        );
    } else {

        # We got something unexpected back
        $response = $self->_handle_error_xml(request => $request, xml_as_hash => $xml_as_hash);
    }

    $self->logger->debug("CancelRequest() returning: " . Dumper($response));

    return $response;
}

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 SEE ALSO

L<PaymentProvider>

=head1 COPYRIGHT

(C) Venda - all rights reserved.

=cut
