#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Signer::AWSv4::S3;

my $signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  method => 'GET',
  key => 'test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
);

my $expected_canon_request = 'GET
/examplebucket/test.txt
X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host
host:s3.amazonaws.com

host
UNSIGNED-PAYLOAD';

cmp_ok($signer->canonical_request, 'eq', $expected_canon_request);

my $expected_string_to_sign = 'AWS4-HMAC-SHA256
20130524T000000Z
20130524/us-east-1/s3/aws4_request
a90abb2891b4f1b1493b9d074672f889072126e1a4881562b0c503d9addd3dff';

cmp_ok($signer->string_to_sign, 'eq', $expected_string_to_sign);

my $signature = '733255ef022bec3f2a8701cd61d4b371f3f28c9f193a1f02279211d48d5193d7';
cmp_ok($signer->signature, 'eq', $signature);


my $expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&X-Amz-Signature=733255ef022bec3f2a8701cd61d4b371f3f28c9f193a1f02279211d48d5193d7';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

$signer = Signer::AWSv4::S3->new(
  time => Time::Piece->strptime('20130524T000000Z', '%Y%m%dT%H%M%SZ'),
  access_key => 'AKIAIOSFODNN7EXAMPLE',
  secret_key => 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
  method => 'GET',
  key => 'test.txt',
  bucket => 'examplebucket',
  region => 'us-east-1',
  expires => 86400,
  version_id => '1234561zOnAAAJKHxVKBxxEyuy_78901j',
  content_type => 'text/plain',
  content_disposition => 'inline; filename=New Name.txt'
);

$expected_signed_qstring = 'X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIOSFODNN7EXAMPLE%2F20130524%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Date=20130524T000000Z&X-Amz-Expires=86400&X-Amz-SignedHeaders=host&response-content-disposition=inline%3B%20filename%3DNew%20Name.txt&response-content-type=text%2Fplain&versionId=1234561zOnAAAJKHxVKBxxEyuy_78901j&X-Amz-Signature=d2f2d969d49edb97b90bf67c652b87eee2449750dd2f14c2e1cbe994f1f5e813';
cmp_ok($signer->signed_qstring, 'eq', $expected_signed_qstring);

done_testing;
