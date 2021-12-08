#' @title Get Parameter Bounds
#' @description  Get parameter bounds that are based on the true values. Not implemented for 2d structures.
#' 
#' @param x A number or vector of the true parameter value(s)
#' @param type A string specifying whether an "upper" or "lower" bound is desired
#' @param p A number specifying the extent of the bound. An extent of 1.0 means that the bound stretches from 0 to 2* the true value (assuming the parameter is positive)
#' @param logScale A boolean indicating whether the bounds should be in log space (TRUE) or not (FALSE)
#'
#' @return A number or vector of parameter bound(s)
#'
#' @family managementProcedure stockAssess
#' 
#' @export

get_bounds <- function(x, 
                       type, 
                       p, 
                       logScale){
  
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
                          
                           # if x is less than zero and the parameter should
                           # not go below zero then set the minimum at the
                           # value for x divided by 10. This ensures that
                           # larger values do not go super-negative with their
                           # bounds but smaller ones will have a lower lower
                           # bound.
                           x <- abs(x) / 10
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
