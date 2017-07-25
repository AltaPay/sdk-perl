package Pensio::Response::PensioAPIPayment;

use strict;
use warnings;
use Moose;

# 'Transaction' => {
#                  'ChargebackEvents' => {},
#                  'FraudRecommendation' => 'Deny',
#                  'FraudExplanation' => 'For the test fraud service the risk score is always equal mod 101 of the created amount for the payment',
#                  'FraudRiskScore' => '49',
#                  'CVVCheckResult' => 'Not_Applicable',
#                  'CreditCardExpiry' => {
#                                        'Year' => '2013',
#                                        'Month' => '01'
#                                      },
#                  'RefundedAmount' => '0.00',
#                  'CreditCardMaskedPan' => '523423*********4234',
#                  'RecurringDefaultAmount' => '0.00',
#                  'Shop' => 'Pensio Functional Test Shop',
#                  'BlacklistToken' => 'edaf0e598b218fe7572a1a95fd2cf7a82ce64044',
#                  'TransactionStatus' => 'captured',
#                  'ReservedAmount' => '49.95',
#                  'AuthType' => 'payment',
#                  'CapturedAmount' => '2.33',
#                  'ReconciliationIdentifiers' => {
#                                                 'ReconciliationIdentifier' => {
#                                                                               'Amount' => {
#                                                                                           'currency' => '978',
#                                                                                           'content' => '2.33'
#                                                                                         },
#                                                                               'Type' => 'captured',
#                                                                               'Id' => '3f57b278-d3eb-4d1c-86f2-da1800aeb6ff',
#                                                                               'Date' => '2013-04-08T22:37:41+02:00'
#                                                                             }
#                                               },
#                  'PaymentInfos' => {},
#                  'PaymentNature' => 'CreditCard',
#                  'UpdatedDate' => '2013-04-08 22:37:41',
#                  'CardHolderCurrency' => '978',
#                  'MerchantCurrency' => '978',
#                  'PaymentNatureService' => {
#                                            'SupportsMultipleRefunds' => 'true',
#                                            'SupportsMultipleCaptures' => 'true',
#                                            'name' => 'TestAcquirer',
#                                            'SupportsRefunds' => 'true',
#                                            'SupportsRelease' => 'true'
#                                          },
#                  'PaymentSchemeName' => 'MasterCard',
#                  'CardStatus' => 'InvalidLuhn',
#                  'Terminal' => 'Pensio Test Terminal',
#                  'CustomerInfo' => {
#                                    'OrganisationNumber' => {},
#                                    'Username' => {},
#                                    'IpAddress' => '127.0.0.1',
#                                    'CustomerPhone' => {},
#                                    'Email' => {},
#                                    'UserAgent' => 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.22 (KHTML, like Gecko) Ubuntu Chromium/25.0.1364.160 Chrome/25.0.1364.160 Safari/537.22'
#                                  },
#                  'CreatedDate' => '2013-04-08 22:37:14',
#                  'CreditCardToken' => 'cac4b4dc50fc20fb3732d369572a5543aa085489',
#                  'ThreeDSecureResult' => 'Not_Attempted',
#                  'TransactionId' => '2',
#                  'ShopOrderId' => '8036c5951886b8cf7dfadd8c62477818'
#                }
#},

has xml => (
    is => 'rw',
    isa => 'HashRef',
);

sub BUILD
{
    my ($self, $xml) = @_;
    
    $self->xml($xml);
    return $self;
}

sub getId()
{
	my ($self) = @_;
	return $self->xml->{TransactionId};
}

sub getReasonCode()
{
	my ($self) = @_;
	return $self->xml->{ReasonCode};
}

sub getPaymentInfo()
{
	my ($self, $key) = @_;
	return $self->xml->{PaymentInfos}->{PaymentInfo}->{$key}->{content};
}

1;