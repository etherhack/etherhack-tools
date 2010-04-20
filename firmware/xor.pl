#!/usr/bin/perl

use strict;
my $xor;
my $data;

while ( read( STDIN, $data, 4 ) ) {
    $data = unpack( "N", $data );
    $xor = $xor ^ $data;
}

printf "%x\n", $xor;
