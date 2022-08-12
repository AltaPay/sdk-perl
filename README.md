# AltaPay - Perl SDK

For integrating Perl projects with the AltaPay gateway.

## API Methods

| Supported Methods         | Methods Not Supported Yet |
|:--------------------------|---------------------------|
| createPaymentRequest      | calculateSurcharge        |
| captureReservation        | credit                    |
| createInvoiceReservation  | fundingList               |
| refundCapturedReservation | fundingDownload           |
| releaseReservation        | getCustomReport           |
| reservation               | getInvoiceText            |
| payments                  | getTerminals              |
| initiatePayment           | queryGiftCard             |
| verify3dSecure            | issueGiftCard             |
| login                     | initiateGiftCardPayment   |
| reserveSubscriptionCharge | testConnection            |
| chargeSubscription        |                           |
| setupSubscription         |                           |
|                           |                           |

## Dependencies

Run the below commands to install the required extensions for the SDK.

    cpan install XML::Simple
    cpan install Moose
    cpan install MooseX::Params::Validate
    cpan install MooseX::Types
    cpan install TAP::Formatter::JUnit
    cpan install Hash::Merge
    cpan install Test::Exception
    cpan install LWP::Protocol::https


## How to run unit tests

Update [ExampleSettings.pm](ExampleSettings.pm) file with the actual gateway and terminal credentials.

Run the below command to run the tests.

    perl TestsSuite.pl

## Changelog

See [Changelog](CHANGELOG.md) for all the release notes.

## License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.

## Documentation

For more details please see [AltaPay docs](https://documentation.altapay.com/)
