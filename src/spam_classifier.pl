#!/usr/bin/perl

use strict;
use warnings;
use POSIX;

sub validate {

    my ($message) = @_;
    $message = formatMessage($message);
    my $spam_index = rand();
    if ($spam_index > .5) {
        return 1;
    }
    return 0
}

sub formatMessage {
    my ($message) = @_;
    $message =~ tr{\n}{ };
    return lc $message;
}
