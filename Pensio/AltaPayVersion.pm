package Pensio::AltaPayVersion;
use strict;

our $VERSION = '1.0.0';

sub new { return bless {}, shift; }

sub version { $VERSION; }

sub user_agent {
    my $self = shift;

    my $perl_version = $^V;
    my $version      = $VERSION;
    my $user_agent   = "sdk-perl/$version Perl/$perl_version";

    return $user_agent;
}
