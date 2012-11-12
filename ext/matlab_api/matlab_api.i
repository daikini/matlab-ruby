%module "matlab::driver::native::API"
%typemap(in) mwSize {
   $1 = NUM2INT($input);
}
%include "carrays.i"
%{
/* Includes the header in the wrapper code */
#include "engine.h"
#include "matrix.h"

#define Init_API Init_matlab_api
%}

/* Parse the header file to generate wrappers */
%include "engine.h"
%include "matrix.h"

%array_class(double, DoubleArray);
