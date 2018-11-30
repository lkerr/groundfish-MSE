

# Function to return lengths-at-age.
# 
# nage: number of ages
# 
# type: type of function function. Available options are
#       *'vonB'
#         L = (Linf + beta1*T) * (1 - exp(-(K + beta2*T) * (ages - t0)))
#       *''
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized. The elements of par must
#      be named according to the variable names given in "type".
#      
# ages: the ages in the model (e.g., 1-15)
# 
# Tanom: temperature anomoly from a baseline level (e.g., a historical
#        average)


get_lengthAtAge <- function(type, par, ages, Tanom=NULL){
  
  if(tolower(type) == 'vonb'){
    
    # if any of the par parameters are NA (i.e., are unused temperature
    # effects) then set them to zero so they will not impact growth at all.
    if(is.na(par['beta1'])){
      par['beta1'] <- 0
    }
    if(is.na(par['beta2'])){
      par['beta2'] <- 0
    }
    
    if(is.null(Tanom)){
      Tanom <- 0
    }
    
    laa <- (par['Linf'] + par['beta1'] * Tanom) * 
           (1 - exp(-(par['K'] + par['beta2'] * Tanom) * (ages - par['t0'])))
  
  }else{
    
    stop('length-at-age type not recognized')
    
  }
  
  
  return(laa)
  
}

