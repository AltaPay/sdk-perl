#!/usr/bin/perl

package Pensio::Examples;

use ExampleSettings;
use ExampleStdoutLogger;
use Data::Dumper;
use Pensio::PensioCallbackHandler;
use Test::Exception;
use Test::More tests => 11;

my $callbackHandler = new Pensio::PensioCallbackHandler();

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<Date>2013-04-09T15:07:29+02:00</Date>
		<Path>API/transactions</Path>
		<ErrorCode>0</ErrorCode>
		<ErrorMessage></ErrorMessage>
	</Header>
	<Body>
		<Result />
		<ResultFilter>
			<TransactionIdEquals>50</TransactionIdEquals>
		</ResultFilter>
		<Transactions>
			<Transaction>
				<TransactionId>50</TransactionId>
				<AuthType>payment</AuthType>
				<CardStatus>InvalidLuhn</CardStatus>
				<CreditCardExpiry>
					<Year>2042</Year>
					<Month>03</Month>
				</CreditCardExpiry>
				<CreditCardToken>a305addef8a5a6ea2dc522e97b8cad29790c8369
				</CreditCardToken>
				<CreditCardMaskedPan>411100******0000</CreditCardMaskedPan>
				<ThreeDSecureResult>Not_Attempted</ThreeDSecureResult>
				<CVVCheckResult>Not_Applicable</CVVCheckResult>
				<BlacklistToken>bdb581c51b07b3e3526ab46dc1537e8ef9c10726
				</BlacklistToken>
				<ShopOrderId>testOrder</ShopOrderId>
				<Shop>Pensio Functional Test Shop</Shop>
				<Terminal>Pensio Test Terminal</Terminal>
				<TransactionStatus>captured</TransactionStatus>
				<MerchantCurrency>978</MerchantCurrency>
				<CardHolderCurrency>978</CardHolderCurrency>
				<ReservedAmount>2.33</ReservedAmount>
				<CapturedAmount>2.33</CapturedAmount>
				<RefundedAmount>0.00</RefundedAmount>
				<RecurringDefaultAmount>0.00</RecurringDefaultAmount>
				<CreatedDate>2013-04-09 08:07:44</CreatedDate>
				<UpdatedDate>2013-04-09 08:07:44</UpdatedDate>
				<PaymentNature>CreditCard</PaymentNature>
				<PaymentSchemeName>Visa</PaymentSchemeName>
				<PaymentNatureService name="TestAcquirer">
					<SupportsRefunds>true</SupportsRefunds>
					<SupportsRelease>true</SupportsRelease>
					<SupportsMultipleCaptures>true</SupportsMultipleCaptures>
					<SupportsMultipleRefunds>true</SupportsMultipleRefunds>
				</PaymentNatureService>
				<ChargebackEvents />
				<PaymentInfos />
				<CustomerInfo>
					<UserAgent></UserAgent>
					<IpAddress></IpAddress>
					<Email><![CDATA[]]>
					</Email>
					<Username><![CDATA[]]>
					</Username>
					<CustomerPhone></CustomerPhone>
					<OrganisationNumber></OrganisationNumber>
				</CustomerInfo>
				<ReconciliationIdentifiers>
					<ReconciliationIdentifier>
						<Id>f5641c11-1e34-4d4c-a1bc-734bec60d0a8</Id>
						<Amount currency="978">2.33</Amount>
						<Type>captured</Type>
						<Date>2013-04-09T08:07:44+02:00</Date>
					</ReconciliationIdentifier>
				</ReconciliationIdentifiers>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

lives_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Response was parsed correctly');




my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<Date>2013-04-09T15:07:29+02:00</Date>
		<Path>API/transactions</Path>
		<ErrorCode>0</ErrorCode>
		<ErrorMessage></ErrorMessage>
	</Header>
	<Body>
		<Result />
		<ResultFilter>
			<TransactionIdEquals>50</TransactionIdEquals>
		</ResultFilter>
		<Transactions>
			<Transaction>
				<TransactionId>50</TransactionId>
				<AuthType>subscriptionAndCapture</AuthType>
				<CardStatus>InvalidLuhn</CardStatus>
				<CreditCardExpiry>
					<Year>2042</Year>
					<Month>03</Month>
				</CreditCardExpiry>
				<CreditCardToken>a305addef8a5a6ea2dc522e97b8cad29790c8369
				</CreditCardToken>
				<CreditCardMaskedPan>411100******0000</CreditCardMaskedPan>
				<ThreeDSecureResult>Not_Attempted</ThreeDSecureResult>
				<CVVCheckResult>Not_Applicable</CVVCheckResult>
				<BlacklistToken>bdb581c51b07b3e3526ab46dc1537e8ef9c10726
				</BlacklistToken>
				<ShopOrderId>testOrder</ShopOrderId>
				<Shop>Pensio Functional Test Shop</Shop>
				<Terminal>Pensio Test Terminal</Terminal>
				<TransactionStatus>captured</TransactionStatus>
				<MerchantCurrency>978</MerchantCurrency>
				<CardHolderCurrency>978</CardHolderCurrency>
				<ReservedAmount>2.33</ReservedAmount>
				<CapturedAmount>2.33</CapturedAmount>
				<RefundedAmount>0.00</RefundedAmount>
				<RecurringDefaultAmount>0.00</RecurringDefaultAmount>
				<CreatedDate>2013-04-09 08:07:44</CreatedDate>
				<UpdatedDate>2013-04-09 08:07:44</UpdatedDate>
				<PaymentNature>CreditCard</PaymentNature>
				<PaymentSchemeName>Visa</PaymentSchemeName>
				<PaymentNatureService name="TestAcquirer">
					<SupportsRefunds>true</SupportsRefunds>
					<SupportsRelease>true</SupportsRelease>
					<SupportsMultipleCaptures>true</SupportsMultipleCaptures>
					<SupportsMultipleRefunds>true</SupportsMultipleRefunds>
				</PaymentNatureService>
				<ChargebackEvents />
				<PaymentInfos />
				<CustomerInfo>
					<UserAgent></UserAgent>
					<IpAddress></IpAddress>
					<Email><![CDATA[]]>
					</Email>
					<Username><![CDATA[]]>
					</Username>
					<CustomerPhone></CustomerPhone>
					<OrganisationNumber></OrganisationNumber>
				</CustomerInfo>
				<ReconciliationIdentifiers>
					<ReconciliationIdentifier>
						<Id>f5641c11-1e34-4d4c-a1bc-734bec60d0a8</Id>
						<Amount currency="978">2.33</Amount>
						<Type>captured</Type>
						<Date>2013-04-09T08:07:44+02:00</Date>
					</ReconciliationIdentifier>
				</ReconciliationIdentifiers>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Do not accept subscriptionAndCapture auth type, as the response does not support this yet');


my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Body>
		<Transactions>
			<Transaction>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if there is no header');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
	
	</Header>
	<Body>
		<Transactions>
			<Transaction>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if there is no error code in the header');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<ErrorCode>
		</ErrorCode>
	</Header>
	
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if there is no body');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<ErrorCode>
		</ErrorCode>
	</Header>
	<Body>
	
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if there is no Transactions tag in body');


my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<ErrorCode>
		</ErrorCode>
	</Header>
	<Body>
		<Transactions>
		
		</Transactions>
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if there is no Transaction tag in the Transactions tag in the body');


my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<ErrorCode>
		</ErrorCode>
	</Header>
	<Body>
		<Transactions>
			<Transaction></Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

dies_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'Die if transaction does not have an auth type');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<Date>2011-08-29T23:48:32+02:00</Date>
		<Path>API/xxx</Path>
		<ErrorCode>0</ErrorCode>
		<ErrorMessage/>
	</Header>
	<Body>
		<Transactions>
			<Transaction>
				<AuthType>paymentAndCapture</AuthType>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

lives_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'If all required tags are there pass for paymentAndCapture authType');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<Date>2011-08-29T23:48:32+02:00</Date>
		<Path>API/xxx</Path>
		<ErrorCode>0</ErrorCode>
		<ErrorMessage/>
	</Header>
	<Body>
		<Transactions>
			<Transaction>
				<AuthType>subscription</AuthType>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

lives_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'If all required tags are there pass for subscription authType');

my $xml = <<END;
<?xml version="1.0"?>
<APIResponse version="20121016">
	<Header>
		<Date>2011-08-29T23:48:32+02:00</Date>
		<Path>API/xxx</Path>
		<ErrorCode>0</ErrorCode>
		<ErrorMessage/>
	</Header>
	<Body>
		<Transactions>
			<Transaction>
				<AuthType>verifyCard</AuthType>
			</Transaction>
		</Transactions>
	</Body>
</APIResponse>
END

lives_ok ( sub { my $response = $callbackHandler->parseXmlResponse($xml); }, 'If all required tags are there pass for verifyCard authType');