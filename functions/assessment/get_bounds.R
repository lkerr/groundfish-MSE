

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



get_bounds <- function(x, type, p, logScale){
  
  if(!type %in% c('upper', 'lower')){
    stop('get_bounds: type should be either upper or lower')
  }
  
  if(any(x <= 0) & logScale){
    stop('get_bounds: x cannot be less than zero if logScale is True')
  }
  
  if(type == 'lower'){
    
    out <- x - p * abs(x)
    
  # vectorize condition where x < 0 using sapply()
  out <- sapply(out, function(x){
                       if(logScale & x <= 0){
                          
                           x <- 1e-6
                           return(x)
                          
                         }else{
                          
                           return(x)
                          
                         }
                      })
    
  }else{
    
    out <- x + p * abs(x)
    
  }

  if(logScale){
    
    out <- log(out)
    
  }
  

return(out)

}



## Testing

# v <- c(exp(14.72))
# ls <- TRUE
# p <- 5
# 
# get_bounds(x = v, type = 'lower', p = p, logScale = ls)
# get_bounds(x = v, type = 'upper', p = p, logScale = ls)



