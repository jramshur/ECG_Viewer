/* avg.c: MEX file that calculates mean
 *
 * a = avg(x) caculates the mean of vector x
 *
 */

#include "mex.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double sum;
  double *x, *avg;
  mwSize mrows,ncols;
  int i;

  /* Check for proper number of arguments. */
  //if(nrhs!=1) {
  //  mexErrMsgTxt("One input required.");
  //} else if(nlhs>1) {
  //  mexErrMsgTxt("Too many output arguments");
  //} 
  
  /* The input must be a noncomplex scalar double.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  
  /* Assign pointers to each input and output. */
  x = mxGetPr(prhs[0]);
  avg = mxGetPr(plhs[0]);
  
 
  sum=0;
  for(i=0; i<=mrows-1; i++)
    sum += x[i];
    
  avg[0] = sum/mrows;
 
}
