/* crosscorr.c: MEX file that calculates cross correlation of two time 
 * series (x,y)
 *
 * rxy = crosscorr(x,y)
 *
 */

#include "mex.h"
#include "math.h"

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
  double sum_x, sum_y, mean_x, mean_y;
  double dx, dy;
  double sum_sq_x, sum_sq_y, sum_coproduct;
  double *x, *y, *rxy;
  int mrowsX,ncolsX,mrowsY,ncolsY;
  int i;

  /* Check for proper number of arguments. */
  if(nrhs!=2) {
  //  mexErrMsgTxt("Two input required.");
  } else if(nlhs>1) {
  //  mexErrMsgTxt("Too many output arguments");
  } 
  
  /* The get size of inputs.*/
  mrowsX = mxGetM(prhs[0]);
  ncolsX = mxGetN(prhs[0]);
  mrowsY = mxGetM(prhs[1]);
  ncolsY = mxGetN(prhs[1]);
  
  /* Check input vector sizes */
  if(mrowsX!=mrowsY) {
    //mexErrMsgTxt("Input vectors must be the same length.");
  } else if( (mrowsX<ncolsX) || (mrowsY<ncolsY) ) {
    //mexErrMsgTxt("Inputs must be in vector format (Mx1)");  
  }
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateDoubleMatrix(1,1, mxREAL);
  
  /*  create a pointer to the input matrix y1 and y2 */
  x = mxGetPr(prhs[0]);
  y = mxGetPr(prhs[1]);
  
  /* Assign pointers to output. */
  rxy = mxGetPr(plhs[0]);
  
  /* Get Mean x,y */
  sum_y=0; sum_x=0;
  for(i=0; i<=mrowsX-1; i++){
    sum_x += x[i];
    sum_y += y[i];
  } 
  
  mean_x = sum_x/mrowsX;
  mean_y = sum_y/mrowsX;
  
  /* Calculate Correlation */
  sum_sq_x=0;
  sum_sq_y=0;
  sum_coproduct=0;
  for(i=0; i<=mrowsX-1; i++)
  {
      dx=x[i]-mean_x;
      dy=y[i]-mean_y;
      sum_sq_x += (dx*dx);
      sum_sq_y += (dy*dy);
      sum_coproduct += (dx*dy);   
  }
  rxy[0] = sum_coproduct/sqrt(sum_sq_x * sum_sq_y);
}
