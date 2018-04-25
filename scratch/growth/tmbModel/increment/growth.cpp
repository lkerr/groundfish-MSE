



#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  // DATA

  // index bounds
  DATA_INTEGER(nyear);
  DATA_INTEGER(nage);
  DATA_INTEGER(mxage);
  DATA_INTEGER(mxyear);
  DATA_INTEGER(nrec);

  // vectors of observation data
  DATA_IVECTOR(YEAR);
  DATA_IVECTOR(AGE);
  DATA_VECTOR(LENGTH);


  // Parameters
  PARAMETER(log_Linf);
    Type Linf = exp(log_Linf);
  PARAMETER(log_K);
    Type K = exp(log_K);
  PARAMETER(log_oe_L);
    Type oe_L = exp(log_oe_L);


  // Containers
  matrix<Type> L(nyear+nage,nage+1);
  vector<Type> Lrec(nrec);
  int indy;
  int inda;
  Type predL;
  Type NLL = 0;
  
 
 
  // Model

  // predictions for length@age in every year of the model

  for(int i=0; i<L.cols(); i++){
    L(0,i) = 0;
  }
  for(int i=0; i<L.rows(); i++){
    L(i,0) = 0;
  }
  // fill in initial length estimates
  for(int y=1; y<nyear+nage; y++){
    for(int a=1; a<nage+1; a++){
      L(y,a) = L(y-1,a-1) + (Linf - L(y-1,a-1)) * (1-exp(-K));
    }
  }


  // negative log likelihood
  for(int i=0; i<nrec; i++){
    //double check the year idx is right ... age was wrong and 
    // I removed the +1.
    indy = nyear-(mxyear-YEAR(i)+1) + nage;
    inda = nage-(mxage-AGE(i));
    predL = L(indy,inda);
    Lrec(i) = predL;
    NLL -= dnorm(log(LENGTH(i)), log(predL), oe_L, true);
  }


  // Report

  REPORT(NLL);
  REPORT(L);
  REPORT(Linf);
  REPORT(K);
  REPORT(oe_L);
  REPORT(Lrec);

  
  return(NLL);
  
}
    

