
# Function to return weight-at-age.
# 
# laa: vector of lengths-at-age
# 
# type: type of function function. Available options are
#       *'aLb'
#        W = par[1] * L^par[2]
#       *''
#       *'input'
#       use vector of weight-at-age, must be same length as number of age classes
#
# par: vector of parameters to use in the function. See function
#      definitions in "type" for the length of the vector and
#      how the function is parameterized
#      
# inputUnit: units for laa vector. Output should be in MT
#           * kg for kilograms
#           * mt for metric tons
#      


get_weightAtAge <- function(type, par, laa, inputUnit){
  
  if(type == 'aLb'){

    waa <- par[1] * laa ^ par[2]

  }else if(type == 'input'){
    
    waa <- par[1:length(par)]
  
    
    }else{

    stop('weight-at-age type not recognized')
  
  }
  
  if(tolower(inputUnit) == 'kg'){
    
    waa <- waa / 1000
    
  }else if(tolower(inputUnit) == 'mt'){

    # do nothing 
  }else{
    
    stop('get_weightAtAge: fix inputUnit')
    
  }
  
  return(waa)
   
}





