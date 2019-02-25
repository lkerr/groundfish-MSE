



#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  // DATA

  DATA_INTEGER(n);
  DATA_VECTOR(A);
  DATA_VECTOR(T);
  DATA_VECTOR(L);

  
  // Parameters
  PARAMETER(log_Linf);
    Type Linf = exp(log_Linf);
  PARAMETER(log_K);
    Type K = exp(log_K);
  PARAMETER(t0);
  PARAMETER(log_sig);
    Type sig = exp(log_sig);
  PARAMETER(beta1);
    // Type beta1 = exp(log_beta1);
  PARAMETER(beta2);
    // Type beta2 = exp(log_beta2);

    
  // Containers
  vector<Type> Lhat(n);
  Type NLL = 0;
  
 
 
  // Model
  for(int i=0; i<n; i++){
    Lhat(i) = (Linf + beta1 * T(i) ) *
              (1 - exp(-(K + beta2 * T(i) ) * (A(i) - t0)));
    // Lhat(i) = Linf * (1 - exp(-K * (A(i) - t0)) );
  }

  // // negative log likelihood
  for(int i=0; i<n; i++){

    NLL -= dnorm(log(L(i)) + 0.00001, 
                 log(Lhat(i)) + 0.00001, sig, true);
    
  }


  // Report
  REPORT(NLL);
  REPORT(L);
  REPORT(A);
  REPORT(T);
  REPORT(Linf);
  REPORT(K);
  REPORT(t0);
  REPORT(Lhat);
  REPORT(beta1);
  REPORT(beta2);

  
  return(NLL);
  
}
    

