#!/usr/bin/perl

use strict;
use warnings;

my $header;    # working copy of the header
my $ixor = 0;  # working copy of the image checksum
my $hxor = 0;  # working copy of the header checksum
my $size = 0;  # length of the image

open( BIX, "+<", $ARGV[0] );
if ( read( BIX, $header, 28 ) != 28 ) { die "Error while reading bix"; }

seek( BIX, 32, 0 );
while ( my $length = read( BIX, my $data, 4 ) ) {
    $size = $size + $length;
    $data = unpack( "N", $data );
    $ixor = $ixor ^ $data;
}

$header =
    substr( $header, 0, 4 )
  . pack( "N", $ixor )
  . substr( $header, 8, 4 )
  . pack( "N", $size )
  . substr( $header, 16, 12 );

for ( my $counter = 0 ; $counter < length $header ; $counter = $counter + 4 ) {
    my $data = substr( $header, $counter, 4 );
    $data = unpack( "N", $data );
    $hxor = $hxor ^ $data;
}

my $packed_hxor = pack( "N", $hxor );
$header = $header . $packed_hxor;

seek( BIX, 0, 0 );
print BIX $header;

printf "Image checksum: %x\n",  $ixor;
printf "Image filesize: %x\n",  $size;
printf "Header checksum: %x\n", $hxor;
