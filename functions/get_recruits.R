

## recruitment functions

# The function returns the recruits given
# parameters as well as vector of environmental covariates and
# environmental data. In the STRAWMAN version there is only a
# super-simple temperature effect

# type: the type of recruitment function
#      *"constant" could be useful in testing.  par for constant is
#       R <- par * Rstoch
#       par[1]: mean recruitment
#       
#      *"ricker" implementation of the Ricker model, in the form
#       R = S*exp(a - b*S + c*tempY)
#       par for the ricker model is
#       par[1]: Ricker a
#       par[2]: Ricker b
#       par[3]: the temperature effect
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



get_recruits <- function(type, par, S, tempY, stoch_sdlog){
  
  # stochastic multiplicitave effect
  Rstoch <- rlnorm(n = 1, meanlog = log(1) - stoch_sdlog^2/2, 
                   sdlog = stoch_sdlog)
  
  if(tolower(type) == 'linear'){
    
    if(length(par) != 2){
      stop('get_recruits: length of par must be 2 with linear
           option')
    }
    
    R <- par[1] * S * (tempY * par[2]) * Rstoch
    
  }
  
  if(tolower(type) == 'ricker'){
    
    if(length(par) != 3){
      stop('get_recruits: length of par must be 3 with ricker
           option')
    }
    
    # (H & W p. 285)
    R <- S * exp(par[1] + par[2]*S + par[3]*tempY) * Rstoch

  }
  
  if(tolower(type) == 'bh'){
    
    stop('BH not yet implemented')
    
  }
  
  if(tolower(type) == 'constant'){
 
    if(length(par) != 2){
      stop('get_recruits: length of par must be 1 with constant
           option')
    }
    
    # include a small deviation because otherwise Rdevs will
    # all be zero which will result in NaN
    R <- par * Rstoch
    
  }
  
  return(R)
  
}



