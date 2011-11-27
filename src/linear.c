#include "linear.h"


struct MatrixRow* new_matrix(void) {

    // Allocate space for the first element
    struct MatrixRow *a = (struct MatrixRow*) malloc(sizeof(struct MatrixRow));
    _verify_allocation( (void *)a );

    // Initialize object to be empty
    a->columns = NULL;
    a->result  = 0;
    a->next    = NULL;

    return a;
}

void destroy_matrix (struct MatrixRow *matrix) {

    struct MatrixRow *current = matrix;

    // Iterate over each item in linked list, freeing as you go.
    while (current != NULL) {
        struct MatrixRow *this = current;
        current = this->next;

        free(this);
        if ( MEMORY_DEBUG ) { printf( "Freed memory at address %p\n", this ); }
    }

}


void add_row (struct MatrixRow *matrix, double columns[], double result) {

    // move through to the last entry
    struct MatrixRow *current = matrix;

    while ( current->next != NULL ) {
        current = current->next;
    }

    // first entry
    if ( current->columns == NULL ) {
        current->columns = columns;
        current->result  = result;
    }

    // All other entries
    else {
        struct MatrixRow *new = malloc(sizeof(struct MatrixRow));
        _verify_allocation( (void *)new );

        new->columns = columns;
        new->result  = result;
        new->next    = NULL;

        current->next     = new;
    }

}

int tune_parameters(struct MatrixRow* matrix, int number_of_weights, double starting_weights[], int iterations, double ending_weights[]) {

    double best_rmse = 1000000;

    // Create a copy of the weights to use as the current weight
    double weights[number_of_weights];
    int i;

    for (i=0; i<number_of_weights; i++) {
        weights[i] = starting_weights[i];
    }

    // for each generation
    for (i=0; i<iterations; i++) {

        // for each parameter
        int j;
        for (j=0;j<number_of_weights;j++) {

            // Tweak one of the weights a bit
            double old_value = weights[j];
            double change = ( rand() % 20000 ) / (double)100000 - .1;
            double new_value = old_value + change;

            weights[j] = new_value;

            // Calculate the RMSE
            double new_rmse = _calculate_rmse(matrix, number_of_weights, weights);
            if (new_rmse < best_rmse) {
                best_rmse = new_rmse;
            }
            else {
                // if its not better, discard this change
                weights[j] = old_value;
            }

        }

    }

    // set ending_weights
    for (i=0; i<number_of_weights; i++) {
        ending_weights[i] = weights[i];
    }

    // returns RMSE
    return (int)(best_rmse*10000);
}

double _calculate_rmse(struct MatrixRow* matrix, int column_count, double weights[]) {

    double sum_of_squares = 0.0;
    int row_count = 0;

    // iterate through entire matrix
    struct MatrixRow *current = matrix;
    while ( current != NULL ) {

        // apply weights
        int i;
        double sum = 0;

        for (i=0; i < column_count; i++) {
            sum += current->columns[i] * weights[i];
        }

        // calculate sum of squares difference
        sum_of_squares += pow( (current->result - sum), 2 );
        row_count++;

        // move the iterator
        current = current->next;
    }

    // return the RMSE
    return ( sqrt(sum_of_squares) / row_count );
}

void _dump_matrix(struct MatrixRow *matrix, int column_count) {

    struct MatrixRow *current_row = matrix;

    int i = 0;
    while ( current_row != NULL ) {

        // for each of the columns, print it
        printf ("[ ");

        int j;
        for ( j=0; j<column_count; j++ ) {
            printf ( "%.4f ", (current_row->columns)[j] );
        }

        // close and add result
        printf("][ %.4f ]\n", current_row->result);

        // move to the next record
        current_row = current_row->next;
        i++;
    }

}

void _verify_allocation( void *a ) {
    if ( a == NULL ) {
        printf ("ERROR: Could not allocate memory for new row.\n");
        exit(1);
    }
    else if ( MEMORY_DEBUG ) {
        printf( "Allocated memory to address %p\n", a );
    }
}

