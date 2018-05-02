


#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  std::cout << "42" << std::endl;
  // these DATA_VECTOR and DATA_INTEGER lines refer to
  // the variables x, y and nobs that are already objects
  // that are declared in the .R file list "data".
  DATA_VECTOR(S);
  DATA_VECTOR(R);
  DATA_VECTOR(T);
  DATA_INTEGER(nobs);

  PARAMETER(log_a);
    Type a = exp(log_a);
  PARAMETER(log_b);
    Type b = exp(log_b);
  PARAMETER(c);
  PARAMETER(theta);
    Type rho = tanh(theta);
  PARAMETER(log_Rhat0);
    Type Rhat0 = exp(log_Rhat0);
  PARAMETER(log_sigR);
    Type sigR = exp(log_sigR);

  vector<Type> Rhat(nobs);
  Type resid0 = 0;
  
  Rhat(0) = Rhat0;
  
  // Include both Ricker and BH models here (safer w/out if statement)
  // Because of the switches only one of the models will be turned on
  // Ricker parameterization from Q&D p. 91
  // BH parameterization from H&W p. 286
  // autocorrelated errors from Q&D p. 117
  for(int i=1; i<nobs; i++){
    resid0 = R(i-1) - Rhat(i-1);
    // Ricker
    Rhat(i) = a * S(i) * exp(-b * S(i) + c * T(i)) + 
              rho * resid0;
  }

  Type NLL =
    -sum(dnorm(log(R), log(Rhat), sigR, true));


  REPORT(S);
  REPORT(R);
  REPORT(T);
  REPORT(a);
  REPORT(b);
  REPORT(c);
  REPORT(rho);
  REPORT(sigR);
  REPORT(Rhat);
  REPORT(NLL);
  
  ADREPORT(a);
  ADREPORT(b);
  ADREPORT(c);
  ADREPORT(rho);
  ADREPORT(sigR);

  return(NLL);
  // return(0);
  
}
