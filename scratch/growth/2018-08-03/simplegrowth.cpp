



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
  PARAMETER(log_gamma);
    Type gamma = exp(log_gamma);


  // Containers
  vector<Type> Lhat(n);
  Type NLL = 0;
  
 
 
  // Model
  for(int i=0; i<n; i++){
    Lhat(i) = (Linf + gamma * T(i)) * (1 - exp(-K * (A(i) - t0)));
  }
// std::cout << log(Lhat) << std::endl;
  // // negative log likelihood
  for(int i=0; i<n; i++){

    // NLL -= dnorm(log(L(i) + 0.0001),
                 // log(Lhat(i) + 0.0001), sig, true);
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
  REPORT(gamma);

  
  return(NLL);
  
}
    

