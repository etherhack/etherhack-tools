#!/usr/bin/perl
 
# Written by the etherhack team
 
# usage: "cat blah.ros | perl unros.pl"
 
use strict;
 
my $footer;
my @files;
 
my $header;
read STDIN, $header, 0x30;
 
my $littleendian = 1;
 
my $done = 0;
my $first = 1;
 
until ($done) {
    my $file;
    my $stuff;
 
    read STDIN, $file->{filename}, 0x10;
    read STDIN, $file->{offset}, 0x04;
    read STDIN, $file->{length}, 0x04;
    read STDIN, $stuff, 0x08;
 
    $file->{filename} = unpack("Z*", $file->{filename});
 
    if ($first) {
        $first = 0;
        if (hex(unpack("H*", $file->{offset})) > 65536) { # probably big endian
            $littleendian = 0;
        }
    }
 
    if (!$littleendian) {
        $file->{offset} = reverse($file->{offset});
        $file->{length} = reverse($file->{length});
    }
 
    $file->{offset} = hex(unpack("H*", $file->{offset}));
    $file->{length} = hex(unpack("H*", $file->{length}));
 
    if ($file->{offset} == "65536") { # FIXME: There's probably a better way to detect the end of the header
        $done=1; # print "Done parsing header\n";
    } else {
        print "Filename: ".$file->{filename}."\n";
        print "Offset: ".$file->{offset}."\n";
        print "Length: ".$file->{length}."\n";
        push @files, $file;
    }
}
 
foreach (@files) {
    my $content;
    my $fh;
 
    open ($fh, ">", $_->{filename});
    read STDIN, $content, $_->{length};
    print $fh $content;
    print "Written ".$_->{length}." bytes to ".$_->{filename}."\n";
}
