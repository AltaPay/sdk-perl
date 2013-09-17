#!/usr/bin/perl

package Pensio::Examples;

use Pensio::Response::PensioCreatePaymentRequestResponse;
use Test::More tests => 2;


subtest 'Test we can create a PensioCreatePaymentRequestResponse with valid Strs ' => sub {

    my $obj =  Pensio::Response::PensioCreatePaymentRequestResponse->new(
        {
            Header => {
                Date=>"2013-09-03",
                Path=>"/some/path",
                ErrorCode=>"is-an-error-code",
                ErrorMessage=>"is-an-err-msg",
            },
            Body => {
                Url=>"url-valid-str",
                Result=>"result-valid-str",
            }
        }
    );

    ok ( $obj->getUrl eq "url-valid-str"    , "url is 'url-valid-str'" );
    ok ( $obj->result eq "result-valid-str" , "result is 'result-valid-str'" );

};

subtest 'Test we can create a PensioCreatePaymentRequestResponse with Undefs for "Url" and "Result" in the "Body"' => sub {

    my $obj =  Pensio::Response::PensioCreatePaymentRequestResponse->new(
         {
            Header => {
                Date=>"2013-09-03",
                Path=>"/some/path",
                ErrorCode=>"is-an-error-code",
                ErrorMessage=>"is-an-err-msg",
            },
            Body => {
            }
        }
    );
    ok ( ! defined ( $obj->getUrl ) , "url can be undefined" );
    ok ( ! defined ( $obj->result ) , "result can be undefined" );

};

