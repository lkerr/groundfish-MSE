

## recruitment functions

# The function returns the recruits given
# parameters as well as vector of environmental covariates and
# environmental data.

# type: the type of recruitment function
# 
#      *"constantMean" could be useful in testing.  par for constantMean is
#       R <- par * Rstoch
#       par[1]: mean recruitment
#       
#      *"rickerlin" implementation of the Ricker model, in the form
#       R = S*exp(a - b*S + c*tempY)
#       par for the ricker linear model is
#       par['a',1]: Ricker a
#       par['b',1]: Ricker b
#       par['c',1]: the temperature effect
#       
#      *"RITS" time series implementation of the ricker model (i.e.,
#       that includes an autocorrelative component
#       R = a * S * exp(-b * S + c * tempY) * error + rho * resid0
#       where resid0 is the residual from the previous year.
#       par['a',1]: Ricker a
#       par['b',1]: Ricker b
#       par['c',1]: temperature effect c
#       par['rho',1]: autocorrelative component rho
#       par['resid0',1]: previous year's recruitment residual
#       
#      *"BHTS" time series implementation of the Beverton Holt model
#       (i.e., that includes an autocorrelative component)
#       R = a * S / (b + S) * exp(c * TempY) * error + rho * resid0;
#       where resid0 is the residual from the previous year.
#       par['a',1]: Ricker a
#       par['b',1]: Ricker b
#       par['c',1]: temperature effect c
#       par['rho',1]: autocorrelative component rho
#       par['resid0',1]: previous year's recruitment residual
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
# tempY: value for temperature in year y
# 
# resid0: Residual recruitment from the previous year (necessary if
#         using models with autocorrelation)



get_recruits <- function(type, par, S, tempY=NULL, resid0=NULL){
  
  # set the parameters as a vector of their own (i.e., remove
  # "type" from the list)
  par1 <- par$par
  
  # if no temperature is included then set to zero (will cancel out
  # in the models)
  if(is.null(tempY)){
    tempY <- 0
  }
  
  # stochastic multiplicitave effect
  Rstoch <- rlnorm(n = 1, meanlog = log(1) - par1['sigR']^2/2, 
                   sdlog = par1['sigR'])
  
  if(tolower(type) == 'rickerlin'){
    
    if(!all(c('a', 'b', 'c') %in% names(par1))){
      stop('get_recruits: check parameters in Ricker linear option')
    }
    
    # (H & W p. 285)
    Rhat <- S * exp(par1['a'] + par1['b']*S + par1['c']*tempY)
    R <- Rhat * Rstoch

  }else if(tolower(type) == 'bhts'){
    
    if(!all(c('a', 'b', 'c') %in% names(par1))){
      stop('get_recruits: check parameters in BHTS option')
    }
    
    # BH parameterization from H&W p. 286
    # meanT is accounting for the centering used in model development.
    Rhat <- par1['a'] * S / (par1['b'] + S) * exp(par1['c'] * 
                                                 (tempY - par[['meanT']]))
    R <- Rhat * Rstoch
    
  }else if(tolower(type) == 'rits'){
    
    if(!all(c('a', 'b', 'c') %in% names(par1))){
      stop('get_recruits: check parameters in RickerTS option')
    }
    
    # Ricker parameterization from Q&D p. 91
    # # meanT is accounting for the centering used in model development.
    Rhat <- par1['a'] * S * exp(-par1['b'] * S + par1['c'] * 
                                                 (tempY - par[['meanT']]))
    R <- Rhat * Rstoch
    
  }else if(tolower(type) == 'constantMean'){
 
    if(length(par1) != 1){
      stop('get_recruits: check parameters in constantMean option')
    }
    
    # include a small deviation because otherwise Rdevs will
    # all be zero which will result in NaN
    R <- par1['a'] * par1['sigR']
    
  }else{
    
    stop('Recruitment type provided not recognized')
  
  }
  R <- unname(R)
  Rhat <- unname(Rhat)

  return(c(R=R, resid=R-Rhat))
  
}



