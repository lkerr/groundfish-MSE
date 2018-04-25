



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
  DATA_VECTOR(avec);
  DATA_INTEGER(nrec);

  // vectors of observation data
  DATA_IVECTOR(YEAR);
  DATA_IVECTOR(AGE);
  DATA_VECTOR(LENGTH);
  DATA_VECTOR(TEMP);


  // Parameters
  PARAMETER(beta0);
  PARAMETER(beta1);
  PARAMETER(log_Linf);
    Type Linf = exp(log_Linf);
  PARAMETER(log_K);
    Type K = exp(log_K);
  PARAMETER(t0);
  PARAMETER(log_oe_L);
    Type oe_L = exp(log_oe_L);


  // Containers
  matrix<Type> gamma(nyear,nage);
  matrix<Type> L(nyear,nage);
  vector<Type> predL(nrec);
  Type theta;
  vector<int> indy(nrec);
  vector<int> inda(nrec);
  Type NLL = 0;
  
 
 
  // Model

  // predictions for length@age in every year of the model

  // // fill in initial length estimates
  for(int y=nage; y<nyear; y++){
    for(int a=0; a<nage; a++){
      gamma(y,a) = 0;
      for(int yy=y-a; yy<=y; yy++){
        // beta0 doesn't really work I guess.  Can't have gamma
        // going negative in this model because it is multiplied
        // by Linf so that will become really small.  Could try
        // having an offset to Linf instead (and get rid of the
        // exp(). But the better solution is the logistic model.
        theta = beta0 + beta1 * (avec(a) - (y-yy));
        gamma(y,a) += theta * TEMP(yy);
      }

      L(y-nage,a) = Linf * exp(gamma(y,a)) * (1 - exp(-K * (avec(a) - t0)));
      // L(y-nage,a) = Linf * (1 - exp(-K * (avec(a) - t0)));

    }
  }
  // std::cout << L << std::endl;

  // // negative log likelihood
  for(int i=0; i<nrec; i++){

    indy(i) = nyear - (mxyear-YEAR(i)+1);
    inda(i) = nage - (mxage-AGE(i)+1);
    // std::cout << inda << " " << AGE(i) << std::endl;
    
    predL(i) = L(indy(i),inda(i));
    
    // NLL += pow((log(LENGTH(i) + 0.0001) - log(predL(i) + 0.0001)),2);
    // NLL += pow((LENGTH(i) - predL(i)),2);
    
    // NLL -= dnorm(LENGTH(i),
    //              predL(i), oe_L, true);

    NLL -= dnorm(log(LENGTH(i) + 0.0001),
                 log(predL(i) + 0.0001), oe_L, true);
    
  }


  // Report

  REPORT(NLL);
  REPORT(L);
  REPORT(Linf);
  REPORT(K);
  REPORT(t0);
  REPORT(beta0);
  REPORT(beta1);
  REPORT(oe_L);
  REPORT(predL);
  REPORT(gamma);
  REPORT(indy);
  REPORT(inda);

  
  return(NLL);
  
}
    

