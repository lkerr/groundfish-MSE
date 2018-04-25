


#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  DATA_VECTOR(x);
  DATA_VECTOR(p);
  
  PARAMETER(dummy);
  
  
  Type LL = -dmultinom(x, p, true);

  REPORT(LL);
  
  return LL;
  
}



