#' @title Percent Relative Error
#' @description Function to report the percent relative error given an estimate and a true value
#' 
#' @param est The estimated value (or vector of values)
#' @param true The true value (or vector of values)
#' 
#' @return A number (or vector of numbers) describing the percent relative error
#' 
#' @family postprocess ???
#' 

get_relE <- function(est, 
                     true){
  
  out <- ((est - true) / true) *100
  
  return(out)
  
}
  
  
  
  


