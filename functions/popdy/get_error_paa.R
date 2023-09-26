#' @title Observation error for proportions-at-age
#' 
#' @param type String describing type of errors implemented, options include:
#' \itemize{
#'  \item{"multinomial" = multinomial errors. Output is divided by the effective sample size so that the function returns proportions}
#' }
#       *"multinomial": multinomial errors. Output is divided by the
#        effective sample size so that the function returns proportions.
#       
#' @param paa A matrix of proportions-at-age (rows are years and sum to 1.0)
#' @param par observation error parameters corresponding to the above type
#' \itemize{
#'  \item{"multinomial" type requires: rmultinom(n=1, size=ess, prob=paa)/par}
#' }
#' 
#' @return Observation error for proportions at age

get_error_paa <- function(type, paa, par,switch){
  
  paaE <- c(rmultinom(n=1, size=par, prob=paa)) / par
  
  return(paaE)
  
}






