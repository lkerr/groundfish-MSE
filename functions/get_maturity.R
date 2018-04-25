

# Function to return the maturity. Maturity functions
# are size-based so a length-at-age vector is necessary.
# 
# type: type of selectivity function. Available options are
#       *'knife'
#         if laa > par, 1; else 0
#       *'logistic'
#         follows L50 parameterization of logistic model
#         p = 1 / ( 1 + exp( par[1] * (par[2] - laa) ) )
#         where par[2] is L50
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#
# laa: length-at-age vector


get_maturity <- function(type, par, laa){
  
  if(tolower(type) == 'knife'){
    
    if(length(par) != 1){
      stop('get_maturity: length of par must be 1 with knife
            option')
    }

    mat <- as.numeric(laa >= par)
  
  }else if(tolower(type) == 'logistic'){
    
    if(length(par) != 2){
      stop('get_maturity: length of par must be 2 with logistic
           option')
    }
    
    # mat <- 1 / (1 + exp(par[1] - par[2] * laa))
    
    # par[2] is L50
    mat <- 1 / (1 + exp(par[1] * (par[2] - laa)))
    
  }
  
  
  return(mat)
  
}






