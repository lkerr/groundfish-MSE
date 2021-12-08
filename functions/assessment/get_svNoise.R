#' @title Pick Starting Assessment Values
#' @description Function generates starting assessment parameter values using a truncated normal distribution to ensure that starting values remain inside the parameter bounds.
#' 
#' @param x A number or a vector of "true" operating model values that you want to provide assessment model starting values for 
#' @param cv A number or vector of CVs for the starting value perturbation (normal scale). This (along with the parameter bounds) governs how much deviation there will be in the assessment model starting value from the "true" operating model value.
#' @param lb A vector of the same length as x that gives the lower bounds for the parameter estimates
#' @param ub A vector of the same length as x that gives the upper bounds for the parameter estimates
#' 
#' @return A number or vector of starting parameter values.
#' 
#' @family managementProcedure stockAssess
#' 
#' @export
#' 
#' @example 
#' get_svNoise(x=0.5, cv=0.1, lb=0, ub=1)

get_svNoise <- function(x, cv, lb, ub){
  
  # add small constant to sd for the case where x = 0
  sd <- abs(cv * x)
  sd <- ifelse(sd != 0, sd, 1e-6)
  newsv <- sapply(1:length(x), function(i)
                                 rtnorm(n=1, mean=x[i], sd=sd[i], 
                                        lower=lb[i], upper=ub[i]))

  return(newsv)
  
}
