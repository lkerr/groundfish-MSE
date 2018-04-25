

# Function to return lengths-at-age.
# 
# nage: number of ages
# 
# type: type of function function. Available options are
#       *'vonB'
#         L = Linf * (1 - exp(-K * (ages - t0)))
#         par[1] = Linf
#         par[2] = K
#         par[3] = t0
#       *''
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# 


get_lengthAtAge <- function(type, par, ages){
  
  if(tolower(type) == 'vonb'){
    
    if(length(par) != 3){
      stop('get_lengthAtAge: length of par must be 3 with vonB
           option')
    }
    
    laa <- par[1] * (1 - exp(-par[2] * (ages - par[3])))
    
  }else{
    
    stop('length-at-age type not recognized')
    
  }
  
  
  return(laa)
  
}

