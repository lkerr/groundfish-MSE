#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
  Type objective_function<Type>::operator() ()
{
  
  
  // these DATA_VECTOR and DATA_INTEGER lines refer to
  // the variables SSBMT, REC, TANOM and NOBS that are already objects
  // that are declared in the .R file list "data".
  DATA_VECTOR(SSBMT);
  DATA_VECTOR(REC);
  DATA_VECTOR(TANOM);
  DATA_INTEGER(NOBS);
  DATA_SCALAR(SSBRF0);
  
  // Parameters that are input from the sr.r file. Estimation is on a log
  // scale 
  PARAMETER(log_h);
    Type h = exp(log_h);
  PARAMETER(log_R0);
    Type R0 = exp(log_R0);
  PARAMETER(beta1);
  PARAMETER(beta2);
  PARAMETER(beta3);
  PARAMETER(log_sigR);
    Type sigR = exp(log_sigR);
  
  vector<Type> Rhat(NOBS);
  vector<Type> hPrime(NOBS);
  vector<Type> R0Prime(NOBS);
  
  
  // Steepness parameterization (Punt et al. Fisheries Research
  // 157 28-40 (2014))
  
  hPrime = h * exp(beta1 * TANOM);
  R0Prime = R0 * exp(beta2 * TANOM);

  // std::cout << beta1 << std::endl;
  // std::cout << TANOM << std::endl;
  // std::cout << exp(beta1 * TANOM) << std::endl;
  // std::cout << hPrime << std::endl;
  // std::cout << "========" << std::endl;

  Rhat = 4 * hPrime * ( SSBMT / (SSBRF0) ) /
         ( (1 - hPrime) + (5*hPrime - 1) * ( SSBMT / (R0Prime * SSBRF0) ) ) *
         exp(beta3 * TANOM);
  std::cout << hPrime << std::endl;
  std::cout << R0Prime << std::endl;
  std::cout << SSBRF0 << std::endl;
  std::cout << Rhat << std::endl;
  std::cout << "========" << std::endl;
  
  // Negative log likelihood function
  Type NLL =
    -sum(dnorm(log(REC), log(Rhat), sigR, true));
  
  
  // Variables to be output to report file
  REPORT(SSBMT);
  REPORT(REC);
  REPORT(TANOM);
  REPORT(SSBRF0);
  REPORT(h);
  REPORT(R0);
  REPORT(beta1);
  REPORT(beta2);
  REPORT(beta3);
  REPORT(sigR);
  REPORT(Rhat);
  REPORT(NLL);
  
  // Variables to estimate standard errors for
  ADREPORT(h);
  ADREPORT(R0);
  ADREPORT(beta1);
  ADREPORT(beta2);
  ADREPORT(beta3);
  ADREPORT(sigR);
  
  // Checkpoint for end-of-code
  std::cout << 43 << std::endl;
  
  return(NLL);
  
  }
