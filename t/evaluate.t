#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 2;

use_ok('Lorzy');

my $result = Lorzy->evaluate([{
    name => 'IfThen',
    args => {
        if_true   => 'yes!',
        if_false  => 'NO!',
        condition => 1,
    },
}]);

is($result, 'yes!');

