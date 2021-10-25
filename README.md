# AltaPay - Perl SDK

For integrating Perl projects with the AltaPay gateway.

## API Methods

| Supported Methods         | Methods Not Supported Yet |
|:------------------------- | ------------------------- |
| createPaymentRequest      | calculateSurcharge        |
| captureReservation        | chargeSubscription        |
| createInvoiceReservation  | credit                    |
| refundCapturedReservation | fundingList               |
| releaseReservation        | fundingDownload           |
| reservation               | getCustomReport           |
| payments                  | getInvoiceText            |
| initiatePayment           | getTerminals              |
| verify3dSecure            | reserveSubscriptionCharge |
| login                     | setupSubscription         |
|                           | queryGiftCard             |
|                           | issueGiftCard             |
|                           | initiateGiftCardPayment   |
|                           | testConnection            |

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

## Contact
Feel free to contact our support team (support@altapay.com) if you need any assistance.