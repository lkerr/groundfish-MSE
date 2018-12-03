

# Function to return the selectivity-at-age. Selectivity functions
# are size-based so a length-at-age vector is necessary.
# 
# type: type of selectivity function. Available options are
#       *'logistic'
#        1 / (1 + exp(par[1] + par[2] * laa))
#       *''
#       
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# laa: length-at-age matrix




get_slx <- function(type, par, laa){
  
  if(tolower(type) == 'logistic'){
  
     slx <- 1 / (1 + exp(par[1] - par[2] * laa))
  
  }
  
  return(slx)
  
}






  
