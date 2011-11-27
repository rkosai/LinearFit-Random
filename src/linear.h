#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define MEMORY_DEBUG 0

struct MatrixRow {
    double *columns;
    double result;
    struct MatrixRow *next;
};

// Publically available methods
struct MatrixRow* new_matrix(void);

void add_row (struct MatrixRow*, double[], double);

int tune_parameters(struct MatrixRow*, int, double[], int, double[]);

void destroy_matrix(struct MatrixRow*);

// Private methods

double _calculate_rmse(struct MatrixRow*, int, double[]);

void _dump_matrix(struct MatrixRow*, int);

void _verify_allocation(void*);

