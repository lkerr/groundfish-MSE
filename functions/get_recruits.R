

## recruitment functions

# The function returns the recruits given
# parameters as well as vector of environmental covariates and
# environmental data. In the STRAWMAN version there is only a
# super-simple temperature effect

# type: the type of recruitment function
# 
#      *"constant" could be useful in testing.  par for constant is
#       R <- par * Rstoch
#       par[1]: mean recruitment
#       
#      *"rickerlin" implementation of the Ricker model, in the form
#       R = S*exp(a - b*S + c*tempY)
#       par for the ricker linear model is
#       par[1]: Ricker a
#       par[2]: Ricker b
#       par[3]: the temperature effect
#       
#      *"rickerTS" time series implementation of the ricker model (i.e.,
#       that includes an autocorrelative component
#       R = a * S * exp(-b * S + c * tempY) * error + rho * resid0
#       where resid0 is the residual from the previous year.
#       par[1]: Ricker a
#       par[2]: Ricker b
#       par[3]: temperature effect c
#       par[4]: autocorrelative component rho
#       par[5]: previous year's recruitment residual
#       
#      *"BHTS" time series implementation of the Beverton Holt model
#       (i.e., that includes an autocorrelative component)
#       R = a * S / (b + S) * exp(c * TempY) * error + rho * resid0;
#       where resid0 is the residual from the previous year.
#       par[1]: Beverton-Holt a
#       par[2]: Beverton-Holt b
#       par[3]: temperature effect c
#       par[4]: autocorrelative component rho
#       par[5]: previous year's recruitment residual
#      
#      
#      
# par: the model parameters (see descriptions of type above)
# 
# S: the total spawning stock size -- mature individuals in weight
# 
# tempY: value for temperature in year y
# 
# stoch_sdlog: sd for lognormally distributed errors



get_recruits <- function(type, par, S, tempY=NULL, stoch_sdlog){
  
  # stochastic multiplicitave effect
  Rstoch <- rlnorm(n = 1, meanlog = log(1) - stoch_sdlog^2/2, 
                   sdlog = stoch_sdlog)
  
  
  if(tolower(type) == 'rickerlin'){
    
    if(length(par) != 3){
      stop('get_recruits: length of par must be 3 with ricker
           option')
    }
    
    # (H & W p. 285)
    Rhat <- S * exp(par[1] + par[2]*S + par[3]*tempY)
    R <- Rhat * Rstoch

  }else if(tolower(type) == 'bhts'){
    
    if(length(par) != 5){
      stop('get_recruits: length of par must be 5 with BHTS
           option')
    }
    
    # BH parameterization from H&W p. 286
    Rhat <- par[1] * S / (par[2] + S) * exp(par[3] * tempY)
    R <- Rhat * Rstoch + par[4] * par[5]
    
  }else if(tolower(type) == 'RickerTS'){
    
    if(length(par) != 5){
      stop('get_recruits: length of par must be 5 with rickerts
           option')
    }
    
    # Ricker parameterization from Q&D p. 91
    Rhat <- par[1] * S * exp(-par[2] * S + par[3] * tempY)
    R <- Rhat * Rstoch + par[4] * par[5]
    
  }else if(tolower(type) == 'constant'){
 
    if(length(par) != 2){
      stop('get_recruits: length of par must be 1 with constant
           option')
    }
    
    # include a small deviation because otherwise Rdevs will
    # all be zero which will result in NaN
    R <- par * Rstoch
    
  }else{
    
    stop('Recruitment type provided not recognized')
  
  }
  
  return(c(R=R, Resid=R-Rhat))
  
}



