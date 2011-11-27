%module "Algorithm::LinearFit::Random::SWIG"

%include "carrays.i"
%array_functions(double, doubleArray)

// Publically available methods

struct MatrixRow* new_matrix(void);
void add_row (struct MatrixRow*, double[], double);
int tune_parameters(struct MatrixRow*, int, double[], int, double[]);
void destroy_matrix(struct MatrixRow*);
void _dump_matrix(struct MatrixRow*, int);

