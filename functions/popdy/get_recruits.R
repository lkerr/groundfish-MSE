

## recruitment functions

# The function returns the recruits. Currently just BH but easily expanded.
# Includes an AR1 process if desired -- for this option must include both
# the desired level of correlation and the previous year's observed and
# expected values (for a residual).

# type: the type of recruitment function
# 
#      *"BH" time series implementation of the Beverton Holt model
#       (i.e., that includes an autocorrelative component)
#       R = a * S / (b + S) * exp(c * TAnom_y) * 
#           exp(rho*(R_ym1-Rhat_ym1) + Rsig);
#       where R_ym1-Rhat_ym1 is the residual from the previous year.
#       par['a']: Ricker a
#       par['b']: Ricker b
#       par['c']: temperature effect c
#       par['rho']: autocorrelative component rho
#       R_ym1: observed recruitment from previous year
#       Rhat_ym1: predicted recruitment from previous year
#      
#      
#      
# par: the model parameters (see descriptions of type above). par must
#      be a matrix of four columns with named rows that correspond
#      to the parameter names listed under 'type' above. Column 1 must
#      be the parameter estimate, column 2 must be the standard error,
#      and columen 3 and 4 must be the lower and upper parameter bounds,
#      respectively. For no parameter uncertainty, set the standard error
#      column equal to zero. If estimates need not be specifically
#      bounded (e.g., temperature coefficient) then use [-Inf,Inf]
# 
# S: the total spawning stock size -- mature individuals in weight
# 
# TAnom_y: value for the temperature anomaly in year y
# 
# pe_R: process error level for recruitment (lognormal scale)
# 
# R_ym1: observed recruitment from previous year
#       
# Rhat_ym1: predicted recruitment from previous year



get_recruits <- function(type, par, SSB, TAnom_y, pe_R, 
                         R_ym1=NULL, Rhat_ym1=NULL){

  if('rho' %in% names(par)){
    
    # Check that values for rho are between -1 and 1 as they should be for
    # correlations
    if(par['rho'] < -1 || par['rho'] > 1){
      
      stop('Rfun: par[rho] must be between 0 and 1')
      
    }
    
    # Check that if rho is provided the values for the residuals are not
    # null (the default)
    if(is.null(R_ym1) || is.null(Rhat_ym1)){
      
      stop('Rfun: if rho is given R_ym1 and Rhat_ym1 must be provided')
      
    }
    
    # Provide warning message if NAs are encountered
    if(is.na(R_ym1) || is.na(Rhat_ym1)){
      
      warning('Rfun: NA encountered in R_ym1 or Rhat_y-1 -- autocorrelation
               error not included')
      R_ym1 <- 1
      Rhat_ym1 <- 1
      
    }
    
  }else{
    
    # if rho is not provided, then set it to 0.0 and set the residuals to
    # numbers > 0 (they will be cancelled automatically since rho is zero)
    par['rho'] <- 0
    R_ym1 <- 1
    Rhat_ym1 <- 1
    
  }
  
  if(type == 'BH'){
 
    # Expected value
    Rhat <- par['a'] * SSB / (par['b'] + SSB) * 
      exp(TAnom_y * par['c'])
    
    # Autocorrelation component
    ac <- par['rho'] * log(R_ym1 / Rhat_ym1)
    
    # Random error component
    rc <- rnorm(1, mean = 0, sd = pe_R)
    
    R <- Rhat * exp(ac + rc)
    
  }else if(type == 'BHSteep'){
  
    XXXXX  
  
  }
 
  out <- c(Rhat = unname(Rhat), R = unname(R))

  return(out)
}



