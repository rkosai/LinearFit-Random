#!/usr/bin/perl

use strict;
use warnings;

use Config;
use FindBin qw/$Bin/;

##################################################

chdir("$Bin/src");

BUILD_SWIG: {
    die "You must have SWIG (www.swig.org) installed to build this module. \n" unless `which swig`;
    print "Building SWIG wrapper...\n";
    `swig -perl5 linear.i`;
}


BUILD_SO: {
    print "Building shared object...\n";
    my $arch = $Config{archlib};
    my $flags = $Config{ccflags};

    # Compile
     die "You must have gcc installed to build this module. \n" unless `which gcc`;
    `gcc -fpic -c -Dbool=char -I$arch/CORE linear.c linear_wrap.c $flags`;

    # Link
     die "You must have ld installed to build this module. \n" unless `which ld`;
    `ld -G linear.o linear_wrap.o -o linear.so`;
}

COPY_LIB: {
    print "Copying files to lib/Algorithm/LinearFit/Random/...\n";
    `mv $Bin/src/linear.so $Bin/lib/auto/Algorithm/LinearFit/Random/SWIG/SWIG.so`;
    `mv $Bin/src/SWIG.pm $Bin/lib/Algorithm/LinearFit/Random/SWIG.pm`;
}

CLEAN_UP: {
    print "Cleaning up...\n";
    `rm $Bin/src/linear_wrap.c`;
    `rm $Bin/src/linear.o`;
    `rm $Bin/src/linear_wrap.o`;
}
