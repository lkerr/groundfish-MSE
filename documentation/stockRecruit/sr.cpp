#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  
  // these DATA_VECTOR and DATA_INTEGER lines refer to
  // the variables SSBMT, REC000S, TANOM and NOBS that are already objects
  // that are declared in the .R file list "data".
  DATA_VECTOR(SSBMT);
  DATA_VECTOR(REC000S);
  DATA_VECTOR(TANOM);
  DATA_INTEGER(NOBS);

  // Parameters that are input from the sr.r file. Estimation is on a log
  // scale 
  PARAMETER(log_a);
    Type a = exp(log_a);
  PARAMETER(log_b);
    Type b = exp(log_b);
  PARAMETER(c);
  PARAMETER(log_sigR);
    Type sigR = exp(log_sigR);
  
  vector<Type> Rhat(NOBS);

  
  // BH parameterization (H&W p. 286)

  Rhat = a * SSBMT / (b + SSBMT) * exp(c * TANOM);
  

  // Negative log likelihood function
  Type NLL =
    -sum(dnorm(log(REC000S), log(Rhat), sigR, true));


  // Variables to be output to report file
  REPORT(SSBMT);
  REPORT(REC000S);
  REPORT(TANOM);
  REPORT(a);
  REPORT(b);
  REPORT(c);
  REPORT(sigR);
  REPORT(Rhat);
  REPORT(NLL);
  
  // Variables to estimate standard errors for
  ADREPORT(a);
  ADREPORT(b);
  ADREPORT(c);
  ADREPORT(sigR);

  // Checkpoint for end-of-code
  std::cout << 43 << std::endl;

  return(NLL);
  
}
