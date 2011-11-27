package Algorithm::LinearFit::Random;

# This file is a wrapper for Algorithm::LinearFit::Random::SWIG, that makes
# the module object-oriented and Perl-friendly.  It also handles most of the
# deallocation of C objects when the module is destroyed.

# POD is at the bottom of the file

use strict;
use warnings;

use Algorithm::LinearFit::Random::SWIG;

sub new {
    my ($class, %param ) = @_;

    unless ( $param{'INPUTS'} ) {
        die "Usage: Algorithm::LinearFit::Random->new( NUMBER_OF_INPUTS )\n";
    }

    my $matrix = Algorithm::LinearFit::Random::SWIG::new_matrix();

    my $ref =  {
        matrix => $matrix,
        width  => $param{'INPUTS'},
        arrays => [],
    };

    return bless($ref, $class);


}

sub add_row {
    my ($self, $inputs, $output) = @_;

    # Verify we have the correct number of inputs
    my $input_count = scalar @$inputs;

    if ( $input_count != $self->width ) {
        die sprintf(
            "Wrong number of input columns.  Got |%i|, expected |%i|\n",
            $input_count,
            $self->width
        );
    }

    # Create a new array containing all the inputs
    my $c_input = Algorithm::LinearFit::Random::SWIG::new_doubleArray( $input_count );
    push ( @{$self->arrays}, $c_input ); #store this reference so we can destroy it later

    # Add the individual items to the array
    for my $i (0..$input_count-1) {
        Algorithm::LinearFit::Random::SWIG::doubleArray_setitem($c_input, $i, $inputs->[$i]);
    }

    # Call add_row
    Algorithm::LinearFit::Random::SWIG::add_row($self->matrix, $c_input, $output);

}

sub tune_parameters {
    my ($self, $starting_weights, $generations) = @_;

    # Create a new array containing all the inputs
    my $input_count = scalar @$starting_weights;
    my $c_weights = Algorithm::LinearFit::Random::SWIG::new_doubleArray( $input_count );
    my $c_outputs = Algorithm::LinearFit::Random::SWIG::new_doubleArray( $input_count );
    push ( @{$self->arrays}, $c_weights, $c_outputs ); #store these two references for later destruction

    # Add the individual items to the array
    for my $i (0..$input_count-1) {
        Algorithm::LinearFit::Random::SWIG::doubleArray_setitem($c_weights, $i, $starting_weights->[$i]);
    }

    my $rmse_times_10k = Algorithm::LinearFit::Random::SWIG::tune_parameters($self->matrix, $self->width, $c_weights, $generations, $c_outputs);
    my $rmse = sprintf("%.5f", $rmse_times_10k / 10000);

    my $output_weights = [];
    for my $i (0..$input_count-1) {
        $output_weights->[$i] = Algorithm::LinearFit::Random::SWIG::doubleArray_getitem($c_outputs, $i);
    }

    return ($rmse, $output_weights);
}


sub _dump {
    my ($self) = @_;
    Algorithm::LinearFit::Random::SWIG::_dump_matrix($self->matrix, $self->width);
}

sub DESTROY {
    my ($self) = @_;

    # clean up all the allocated arrays
    for my $a ( @{$self->arrays} ) {
        Algorithm::LinearFit::Random::SWIG::delete_doubleArray($a);
    }

    # destroy the matrix
    Algorithm::LinearFit::Random::SWIG::destroy_matrix($self->matrix);
}

sub matrix { return $_[0]->{'matrix'} }
sub width  { return $_[0]->{'width'}  }
sub arrays { return $_[0]->{'arrays'} }


=pod

=head1 NAME

Algorithm::LinearFit::Random - Estimate an n-dimensional multiple linear regression

=head1 SYNOPSIS

    #!perl -w
    use Algorithm::LinearFit::Random;

    my $matrix = new Algorithm::LinearFit::Random( INPUTS => 3 );
    $matrix->add_row( [6, -4, 5] , 4.00 );
    $matrix->add_row( [1,  3, 8] , 2.50 );

    my $generations = 1_000_000;
    my $starting_weights = [0, 0, 0];

    # Optimize weights for smallest RMSE
    my ( $rmse, $ending_weights ) = $matrix->tune_parameters( $starting_weights, $generations );

=head1 SUMMARY

This module can be used to efficiently estimate a multiple linear regression in
n-dimensional space.  This is typically most useful in inconsistent,
overdetermined matrices where the "best fit" line is desired.

The method it uses to do this is to randomly adjust parameters, and check if
the resulting fit is better (has a lower RMSE) than the previous version.  Over
the course of several generations, the parameters converge on a solution that
produces the minimum error.

This means that the the parameters may get "stuck" in a local minima.  Optimal
selection of the random adjustment function may help prevent this problem.

Since the bulk of this module is written in C, it is pretty fast.  On my own
datasets, it runs over 100x faster than the pure Perl equivalent.

=head1 DESCRIPTION

=over 4

=item $matrix = Algorithm::LinearFit::Random->new( INPUTS => $count )

OOP interface to the rest of the module.  Currently the only flag is INPUTS,
which takes the number of parameter columns.  The add_row function must adhere
to this number of INPUTS.

=item $matrix->add_row( $input_arrayref, $output )

Add rows to the matrix.  Inputs are added via $input_arrayref, sized the same
as the INPUTS flag originally passed to the constructor. Output is a scalar
output value for these parameters.  This method may be called multiple times to
add more rows to the matrix.

=item ($rmse, $ending_weights) = $matrix->tune_parameters( $starting_weights, $generations )

The heavy lifting of the module.  Tunes the parameters using the method
described in the summary.  Accepts an arrayref of starting weights (the number
matching the number of INPUTS) and the number of generations to perform before
returning.

This function returns the final RMSE, and a arrayref of the estimated parameter
weights.

=item $matrix->dump

Utility method to print the current contents of the matrix.  While this is useful
for debugging purposes, it's format should not be relied upon, because it may
change in the future.

=back

=head1 AUTHOR

Ryan Kosai E<lt>github@ryankosai.comE<gt>, http://www.github.com/rkosai/

=cut


1;
