#' @title Get Proportion-At-Age Error
#' @description 
#' 
#' @param type A string specifying the type of error to implement (@seealso \code{\link{runSims}} oe_paaIN_typ parameter for full documentation of type) 
#' @param paa A matrix of proportions-at-age (rows are years, each row sums to 1.0)
#' @param par Parameters associated with selected type (??? appears to be hard coded in get_proj, here effective sample size, should this be passed in from the stockEnv$oe_paaIN parameter?)
#' 
#' @return Proportions (a vector? a matrix? check???)
#' 
#' @family operatingModel, population, projection
#' 


# Function to return observation error for proportions-at-age
# 
# type: type of errors implemented
#       *"multinomial": multinomial errors. Output is divided by the
#        effective sample size so that the function returns proportions.
#       
# paa: matrix of proportions-at-age (rows are years and sum to 1.0)
# 
# par: observation error parameters
#      multinomial: rmultinom(n=1, size=ess, prob=paa) / par


get_error_paa <- function(type, 
                          paa, 
                          par){
  
  paaE <- c(rmultinom(n=1, size=par, prob=paa)) / par # Output is divided by the effective sample size so that the function returns proportions.
  
  return(paaE)
}
