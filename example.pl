#!/usr/bin/perl

use FindBin qw/$Bin/;
use lib "$Bin/lib";

use Algorithm::LinearFit::Random;

##################################################


# Build up a matrix of data

my $matrix = new Algorithm::LinearFit::Random( INPUTS => 3 );
$matrix->add_row( [6, -4, 5] , 4.00 );
$matrix->add_row( [1,  4, 6] , 3.00 );
$matrix->add_row( [2,  8, 7] , 6.00 );
$matrix->add_row( [1,  3, 8] , 2.50 );


# Display the matrix to verify it was added correctly

$matrix->_dump();


# Optimize weights for smallest RMSE

my $generations = 1_000_000;
my $starting_weights = [0, 0, 0];
my ( $rmse, $ending_weights ) = $matrix->tune_parameters( $starting_weights, $generations );


# Display calculated weights after N generations
print "\n";
print "Generations: $generations\n";
print "RMSE: $rmse\n";
print "Weights: [ " . join(' ', map { sprintf("%.4f", $_) } @$ending_weights ) . " ]\n";


