



#include <TMB.hpp>  // Links in the TMB libraries

// must include the next two lines
template<class Type>
Type objective_function<Type>::operator() ()
{
  
  // DATA
  
  // index bounds
  DATA_INTEGER(ncaayear);
  DATA_INTEGER(nage);
  
  // Catch
  DATA_VECTOR(obs_sumCW);
  DATA_MATRIX(obs_paaCN);
  
  // Index
  DATA_VECTOR(obs_sumIN);
  DATA_MATRIX(obs_paaIN);
  
  // Fishing effort
  DATA_VECTOR(obs_effort);
  
  // ESS
  DATA_SCALAR(oe_paaCN);
  DATA_SCALAR(oe_paaIN);
  
  // len/wt-at-age
  DATA_MATRIX(laa);
  DATA_MATRIX(waa);
  
  // survey data
  DATA_MATRIX(slxI); // survey selectivity
  DATA_SCALAR(timeI); // survey timing as proportion of year
  
  // environmental data
  DATA_VECTOR(TAnom_std); // standardized (z-score) temperature anomaly
  
  // Type of recruitment deviations
  DATA_INTEGER(R_dev_typ);
  
  // Use temperature to inform Rdevs? 0:no 1:yes
  DATA_INTEGER(R_dev_tempNum)
  
  
  // PARAMETERS (and arithmetic scale containers)
  PARAMETER(log_M);
    matrix<Type> M(ncaayear,nage);
    M.fill(exp(log_M));
  PARAMETER_VECTOR(R_dev);
  PARAMETER(log_R_dev_mean);
  PARAMETER(log_ipop_mean);
  PARAMETER_VECTOR(ipop_dev);
 
 
  // Catchabilities
  PARAMETER(log_qC);
  PARAMETER(log_qI);
    Type qC = exp(log_qC);
    Type qI = exp(log_qI);
 
  
  // Selectivity
  PARAMETER_VECTOR(log_selC);
    vector<Type> selC = exp(log_selC);
    
  // SDs
  PARAMETER(log_oe_sumCW);
  PARAMETER(log_oe_sumIN);
  PARAMETER(log_pe_R);
  PARAMETER(slp_Tanom);
  // PARAMETER(log_oe_ipop_dev);
  Type oe_sumCW = exp(log_oe_sumCW);
  Type oe_sumIN = exp(log_oe_sumIN);
  Type pe_R = exp(log_pe_R);
  // Type oe_ipop_dev = exp(log_oe_ipop_dev);
  
  
  // Other necessary containers
  
  // age maximum indices (becuase tmb starts at
  // index 0)
  int amxi = nage - 1;
  
  // selectivity
  matrix<Type> slxC(ncaayear,nage);
  
  // mortality
  vector<Type> F_full(ncaayear); // (fully-selcted)
  matrix<Type> F(ncaayear,nage);
  matrix<Type> Z(ncaayear,nage);
  
  // Recruitment
  vector<Type> R(ncaayear);
  
  // N matrix
  matrix<Type> J1N(ncaayear,nage);
  
  // Predicted values
  matrix<Type> CN(ncaayear,nage);     // predicted catch numbers
  matrix<Type> CW(ncaayear,nage);     // predicted catch weight
  vector<Type> sumCW(ncaayear);       // predicted catch weight sum
  matrix<Type> IN(ncaayear,nage);     // predicted index
  vector<Type> sumIN(ncaayear);       // predicted index sum
  matrix<Type> paaCN(ncaayear,nage);  // predicted catch paa
  matrix<Type> paaIN(ncaayear,nage);  // predicted index paa
  

  // Calculate selectivity -- note that TMB seems to be picky about
  // using subtraction on the same line as vector multiplications
  // (or something like that) so set up some temporary vectors as
  // intermediates. Full function is commented out.
  for(int y=0; y<ncaayear; y++){
    vector<Type> tsel0(nage);
    vector<Type> tsel1(nage);
    tsel0 = selC(1) * laa.row(y);
    tsel1 = selC(0) - tsel0;
    slxC.row(y) = 1 / (1 + exp(tsel1));
    // slxC.row(y) = 1 / (1 + exp(selC(0) - selC(1) * laa.row(y)));
  }
  
  
  // Mortality
  F_full = qC * obs_effort;
  for(int y=0; y<ncaayear; y++){
    F.row(y) = slxC.row(y) * F_full(y);
  }
  Z = F + M;


  // Initial population
  J1N.row(0) = exp(log_ipop_mean + ipop_dev);


  // Recruitment
  // ENVIRONMENTAL VARIABLES: Get rid of the random walk and make sure that 
  // the environmental
  // variables are something like Zscores and are on the same scale as the 
  // recruitment deviations
  // (so they should also be Z scores or something once they get down to the 
  // likelihood function)
  R(0) = J1N(0,0);
  for(int y=1; y<ncaayear; y++){
    // note Rdevs go from 0 to n-1 so here R_dev(y-1) does actually
    // refer to the Rdev in the last year.
    if(R_dev_typ == 0){
      R(y) = exp(log_R_dev_mean + R_dev(y-1));
    }else{
      R(y) = exp(log(R(y-1)) + R_dev(y-1));
    }
  }


  // Fill the N-at-age matrix
  J1N.col(0) = R;
  
  for(int y=1; y < ncaayear; y++){
    for(int a=1; a < amxi; a++){
      J1N(y,a) = J1N(y-1,a-1) * exp(-Z(y-1,a-1));
    }
    J1N(y,amxi) = J1N(y-1,amxi) * exp(-Z(y-1,amxi)) +
      J1N(y-1,amxi-1) * exp( -Z(y-1,amxi-1) );
  }

  // Calculate expected catch-at-age in numbers and weight and
  // total annual catch in weight
  CN = F.array() / Z.array() * J1N.array() * (1 - exp(-Z.array()));
  CW = CN.array() * waa.array();
  sumCW = CW.rowwise().sum();

  // Calculate expected index-at-age in numbers and the total
  // annual index in numbers
  IN = slxI.array() * qI * J1N.array() * exp(-Z.array() * timeI);
  sumIN = IN.rowwise().sum();

  // Calculate the expected proportions-at-age for catch and index, both
  // in numbers
  for(int y=0; y<ncaayear; y++){
    paaCN.row(y) = CN.row(y) / CN.row(y).sum();
    paaIN.row(y) = IN.row(y) / IN.row(y).sum();
  }



  // negative log likelihood

  Type NLL_sumCW =
    -sum(dnorm(log(obs_sumCW), log(sumCW), oe_sumCW, true));
  Type NLL_sumIN = 
    -sum(dnorm(log(obs_sumIN), log(sumIN), oe_sumIN, true));
  
  Type NLL_R_dev;
  if(R_dev_tempNum == 0){
    NLL_R_dev = -sum(dnorm(R_dev, 0, pe_R*2, true));
  }else{
    NLL_R_dev = -sum(dnorm(R_dev, TAnom_std*slp_Tanom, pe_R, true));
  }

  // TMB doesn't seem to like doing calculations inside the multinomial
  // function so use temporary vectors first.
  vector<Type> temp1(ncaayear);
  vector<Type> temp2(ncaayear);
  Type NLL_paaCN = 0;
  Type NLL_paaIN = 0;

  for(int y=0; y<ncaayear; y++){
    // catch proportions
    temp1 = obs_paaCN.row(y) * oe_paaCN;
    temp2 = paaCN.row(y);
    NLL_paaCN -= dmultinom(temp1, temp2, true);
    
    // index proportions
    temp1 = obs_paaIN.row(y) * oe_paaIN;
    temp2 = paaIN.row(y);
    NLL_paaIN -= dmultinom(temp1, temp2, true);
  }
    
  Type NLL = NLL_sumCW +
             NLL_sumIN +
             NLL_R_dev +
             NLL_paaCN +
             NLL_paaIN;
  
  // Report
  
  // Setup
  REPORT(ncaayear);
  REPORT(nage);
  
  // Data
  REPORT(obs_sumCW);
  REPORT(obs_paaCN);
  REPORT(obs_sumIN);
  REPORT(obs_paaIN);
  REPORT(obs_effort);
  REPORT(laa);
  REPORT(waa);
  
  // ESS
  REPORT(oe_paaCN);
  REPORT(oe_paaIN);
  
  // Parameters and arithmetic scale containers
  REPORT(log_M);
  REPORT(M);
  REPORT(R_dev);
  REPORT(log_ipop_mean);
  REPORT(ipop_dev);
  
  REPORT(oe_sumCW);
  REPORT(oe_sumIN);
  REPORT(log_pe_R);
  // REPORT(oe_ipop_dev);
  REPORT(pe_R);
  
  REPORT(log_selC);
  REPORT(selC);
  
  REPORT(log_qC);
  REPORT(log_qI);
  REPORT(qC);
  REPORT(qI);
  
  REPORT(slxI);
  REPORT(timeI);
  
  REPORT(amxi);
  REPORT(slxC);
  REPORT(F_full);
  REPORT(F);
  REPORT(Z);
  REPORT(R);
  REPORT(J1N);
  
  REPORT(CN);
  REPORT(CW);
  REPORT(sumCW);
  REPORT(IN);
  REPORT(sumIN);
  REPORT(paaCN);
  REPORT(paaIN);
  
  REPORT(NLL);
  REPORT(NLL_sumCW);
  REPORT(NLL_sumIN);
  REPORT(NLL_R_dev);
  REPORT(NLL_paaCN);
  REPORT(NLL_paaIN);
  
  
  // Type NLL = 0;
  return(NLL);
  
}
    

