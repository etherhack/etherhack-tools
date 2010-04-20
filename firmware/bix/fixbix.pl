#!/usr/bin/perl

use strict;

my $header;    # working copy of the header
my $ixor;      # working copy of the image checksum
my $hxor;      # working copy of the header checksum
my $size;      # length of the image

open( BIX, "+<", $ARGV[0] );
if ( read( BIX, $header, 28 ) != 28 ) { die "Error while reading bix"; }

seek( BIX, 32, 0 );
while ( my $length = read( BIX, my $data, 4 ) ) {
    $size = $size + $length;
    $data = unpack( "N", $data );
    $ixor = $ixor ^ $data;
}

$header
    = substr( $header, 0, 4 )
    . pack( "N", $ixor )
    . substr( $header, 8, 4 )
    . pack( "N", $size )
    . substr( $header, 16, 12 );

for ( my $counter = 0; $counter < length $header; $counter = $counter + 4 ) {
    my $data = substr( $header, $counter, 4 );
    $hxor = $hxor ^ $data;
}

$header = $header . $hxor;

seek( BIX, 0, 0 );
print BIX $header;

printf "Image checksum: %x\n",  $ixor;
printf "Image filesize: %x\n",  $size;
printf "Header checksum: %x\n", $hxor
