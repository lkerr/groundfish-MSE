

# A function to generate correlated random values to use in a
# stock recruitment function. Before each iteration of the simulation
# this function should be run to generate parameters that will be
# used for that particular iteration.
# 
# Depending on the parameters that are given the behavior of the
# function will change. If no standard errors or covariance matrix
# is given, the function will pass the input parameters directly
# (i.e., there will be no stochasticity). Stochasticity can also
# be turned on or off directly with the 'stochastic' parameter.
# 
# 
# par: Parameters derived from a stock-recruit model. This must be
#      a list that ALWAYS includes:
#        (1) "type" for the type of S/R model (type options are 
#            'constantMean', 
#            'rickerlin', 
#            'RITS' (for Ricker model) and
#            'BHTS' (for beverton-holt)) 
#        (2) a vector of parameter names
#        (3) a vector of parameters
#      and MAY include
#        (4) a vector of standard errors
#        (5) a variance-covariance matrix
#        (6) lower bounds for parameters
#        (7) upper bounds for parameters
#        
# stochastic: should the function return a realization of the parameters
#             including uncertainty? This should generally be true, but
#             may be worth turning off for testing.
# 



get_recruitment_par <- function(par, stochastic=TRUE){
  
  # if stochastic is FALSE then just return the given
  # parameter values with no uncertainty
  if(!stochastic){
    
    par1 <- list(type = par$type,
                 names = par$names,
                 par = par$par,
                 meanT = par$meanT)
    
    return(par1)
    
  }else{
  
    # if no parameter bounds are given, make them -Inf and Inf
    if(is.null(par$upper)){
      par$upper <- rep(Inf, length(par$names))
    }
    if(is.null(par$lower)){
      par$lower <- rep(-Inf, length(par$names))
    }
    
    # if no variance-covariance matrix is given, make one with
    # zeros (and a diagonal of the variance)
    if(is.null(par$cov)){
      if(is.null(par$se)){
        stop('get_recruitment_par: if is.null(par$cov) = TRUE 
             then must provide par$se')
      }else{
        par$cov <- matrix(0, nrow=length(par$names), 
                          ncol=length(par$names))
        diag(par$cov) <- par$se^2
      }  
    }
    
    # Generate random values for each of the parameters
    # c() makes the returned matrix into a vector
    par1 <- c(rtmvnorm(1, mean=par$par, sigma=par$cov,
                       lower=par$lower, upper=par$upper))
    names(par1) <- par$names
    
    return(list(type=par$type, 
                par=par1,
                meanT = par$meanT))
  
  }

}





