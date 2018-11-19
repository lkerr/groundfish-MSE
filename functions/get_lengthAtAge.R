

# Function to return lengths-at-age.
# 
# nage: number of ages
# 
# type: type of function function. Available options are
#       *'vonB'
#         L = (Linf + beta1*T) * (1 - exp(-(K + beta2*T) * (ages - t0)))
#         par[1] = Linf
#         par[2] = K
#         par[3] = t0
#         par[4] = beta1
#         par[5] = beta2
#       *''
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# 


get_lengthAtAge <- function(type, par, ages, TempY=NULL){
  
  if(tolower(type) == 'vonb'){
    
    # if any of the par parameters are NA (i.e., are unused temperature
    # effects) then set them to zero so they will not impact growth at all.
    if(any(is.na(par))){
      par[is.na(par)] <- 0
    }
    
    # If there are only 3 or 4 parameters adapt par so that it is zero
    # instead of NA. There is surely a better way to do this...
    if(is.na(par[4])){
      par[4] <- 0
    }
    if(is.na(par[5])){
      par[5] <- 0
    }
    
    if(is.null(TempY)){
      TempY <- 0
    }
    
    laa <- (par[1] + par[4] * TempY) * 
           (1 - exp(-(par[2] + par[5] * TempY) * (ages - par[3])))
    
  }else{
    
    stop('length-at-age type not recognized')
    
  }
  
  
  return(laa)
  
}

