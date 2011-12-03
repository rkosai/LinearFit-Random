#include "linear.c"

#define DIMENSIONS 3

void print_weights(double[]);

int main () {

    // initiate new linked list
    struct MatrixRow *matrix = new_matrix();

    double w[DIMENSIONS] = { 6, -4, 5 };
    double x[DIMENSIONS] = { 1, 4, 6 };
    double y[DIMENSIONS] = { 2, 8, 7 };
    double z[DIMENSIONS] = { 1, 3, 8 };

    add_row( matrix, w, 4.0 );
    add_row( matrix, x, 3.0 );
    add_row( matrix, y, 6.0 );
    add_row( matrix, z, 2.5 );

    // print contents of matrix to demonstrate it works properly
    _dump_matrix(matrix, DIMENSIONS);

    // perform parameter tuning
    double starting_weights[DIMENSIONS] = { 0, 0, 0 };
    int iterations = 100000;

    double ending_weights[DIMENSIONS] = { 0, 0, 0 };
    double RMSE = tune_parameters(matrix, DIMENSIONS, starting_weights, iterations, ending_weights) / 10000;

    // demonstrate output results
    printf ("RMSE: %.5f\n", RMSE);
    printf ("WEIGHTS: ");
    print_weights(ending_weights);

    // recursively clean up matrix
    destroy_matrix(matrix);

    return 0;
}

void print_weights(double weights[]) {
    int i;
    printf ("[ ");
    for ( i=0; i<DIMENSIONS; i++ ) {
        printf ("%.4f ", weights[i]);
    }
    printf ("]\n");

}
