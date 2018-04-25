


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
  PARAMETER(c);
  PARAMETER(log_sigR);
  Type sigR = exp(log_sigR);

  vector<Type> Rhat(nobs);
  for(int i=0; i<nobs; i++){
    Rhat(i) = a * S(i)* exp(b * S(i) + c * T(i));
  }

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

  return(NLL);
  // return(0);
  
}
