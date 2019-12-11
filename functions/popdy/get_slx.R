

# Function to return the selectivity-at-age. Selectivity functions
# are size-based so a length-at-age vector is necessary. If the 'const'
# argument is used for type the selectivity function simply returns
# the input parameter.
# 
# type: type of selectivity function. Available options are
#       *'logistic'
#        1 / (1 + exp(par[1] + par[2] * laa))
#       *'const'
#        par[1]
#       *'input'
#        par[1:length(par)]
#       
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# laa: length-at-age matrix




get_slx <- function(type, par, laa=NULL){
  
  if(tolower(type) == 'logistic'){
  
     slx <- 1 / (1 + exp(par[1] - par[2] * laa))
  
  }
  
  if(tolower(type) == 'const'){
    
    if(par[1] < 0 || par[1] > 1){
      stop('constant selectivity parameters need to be between zero and 1')
    }
    
    slx <- par[1]
    
  }
  
  if(tolower(type) == 'input'){
    if(par < 0 | par > 1){
      stop('constant selectivity parameters need to be between zero and 1')
    }
    
    slx <- par[1:length(par)]
  }
  
  return(slx)
  
}






  
