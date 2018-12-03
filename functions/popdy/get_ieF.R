

# Implementation error for fishing mortality -- the actual fishing
# mortality is unlikely to be exactly the value recommended by
# management.
# 
# type: distribution type for the error
#       *lognormal
#       
# F: the fishing mortality recommended through the management procedure
#    process
#    
# par: parameters associated with "type" (for example, sdlog for lognormal
#      distribution
# 



get_ieF <- function(type, F, par){
  
  if(type == 'lognormal'){
    
    ieF <- rlnorm(1, meanlog = F, sdlog = par)
    
  }
  
  return(ieF)
}

