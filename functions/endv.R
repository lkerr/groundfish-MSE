#' @title Return last value 
#' @description Return the last value of a vector (just a space-saver). 
#' 
#' @param x A vector or a single-column matrix for which you want the last value.
#' 
#' @return The last item in the vector or matrix
#' 
#' @family ???
#' 

endv <- function(x){
  
  if(is.matrix(x)){
    
    x <- c(x)
    
  }
  
  return(tail(x, 1))
}
