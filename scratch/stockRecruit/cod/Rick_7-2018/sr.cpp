


#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  
  // these DATA_VECTOR and DATA_INTEGER lines refer to
  // the variables x, y and nobs that are already objects
  // that are declared in the .R file list "data".
  DATA_VECTOR(S);
  DATA_VECTOR(R);
  DATA_VECTOR(T);
  DATA_INTEGER(nobs);

  PARAMETER(log_a);
    Type a = exp(log_a);
  PARAMETER(b);
    // Type b = exp(log_b);
  PARAMETER(c);
  PARAMETER(log_sigR);
    Type sigR = exp(log_sigR);
  
  vector<Type> Rhat(nobs);

  
  // Include both Ricker and BH models here (safer w/out if statement)
  // Because of the switches only one of the models will be turned on
  // Ricker parameterization from Q&D p. 91
  // BH parameterization from H&W p. 286
  // autocorrelated errors from Q&D p. 117

  // Ricker
  Rhat = S * exp(a - b*S + c * T);
  

  Type NLL =
    -sum(dnorm(log(R), log(Rhat), sigR, true));


  REPORT(S);
  REPORT(R);
  REPORT(T);
  REPORT(a);
  REPORT(b);
  REPORT(c);
  REPORT(sigR);
  REPORT(Rhat);
  REPORT(NLL);
  
  ADREPORT(a);
  ADREPORT(b);
  ADREPORT(c);
  ADREPORT(sigR);

  
  std::cout << 43 << std::endl;

  return(NLL);
  // return(0);
  
}
