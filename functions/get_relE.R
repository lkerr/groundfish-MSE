#' @title 
#' @description Function to report the percent relative error given an estimate and a true value
#' 
#' @param est the estimated value (or vector of values)
#' @param true the true value (or vector of values)
#' 
#' @return The relative error for a value (or vector of values)

get_relE <- function(est, true){
  
  out <- ((est - true) / true) *100
  
  return(out)
  
}
  
  
  
  


