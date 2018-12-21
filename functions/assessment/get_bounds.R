

# function to get parameter bounds that are based on the
# true values. Not implemented for 2d structures.
# 
# x: the true paramter value(s) - could be a number or a vector
# 
# type: either "upper" or "lower", indicating whether an upper or lower
#       bound is desired
#
# p: the extent to which the bound goes. An extent of 1.0 means
#    that the bound stretches from 0 to 2* the true value (assuming
#    the parameter is positive)



get_bounds <- function(x, type, p){
  
    if(!type %in% c('upper', 'lower')){
      stop('get_bounds: type should be either upper or lower')
    }
    
    if(type == 'lower'){
      
      out <- x - p * abs(x)
      
    }else{
      
      out <- x + p * abs(x)
      
    }
    

  return(out)
  
}


