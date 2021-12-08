#' @title Initial Numbers-At-Age
#' @description Get initial population. F and M are provided separately rather than Z because the M should probably be the same as in the rest of the simulation. Varying this function should have no impact on the simulation results because a long enough burn in period would be used to nullify any initial effects.
#' 
#' @param type A string specifying the method to calculate initial numbers-at-age, options are:
#' \itemize{
#'   \item{"expDecline" - }
#'   \item{"input" - Use initial numbers-at-age provided}
#' }
#' @param par A vector of parameters used to calculate initial numbers-at-age, depend on specified type:
#' \itemize{
#'   \item{If type = "expDecline", par is a named vector of number of ages 'nage', population numbers in the first age 'N0', a value for fishing mortality 'F', and a value for natural mortality 'M'}
#'   \item{If type = "input", par is a vector of numbers-at-age}
#' }
#' @return A vector of starting numbers-at-age. If type = "expDecline" generated assuming equilibrium conditions.
#' 
#' @family operatingModel, population
#' 
#' @export

# type: how to create initial numbers-at-age. Available options are
#
#     *'expDecline' calculated as N0 * exp((-F_full - M) * 0:(nage-1)) where:
#        par[nage]: number of ages in the simulation
#        par[N0]: population numbers in the first age
#        par[F]: value for fishing mortality
#        par[M]: value for natural mortality (probably should be the same as in
#        the rest of the simulation)
#
#     *'input' 
#        give a vector of initial numbers-at-age

get_init <- function(type, 
                     par){
  
  if(type == "expDecline"){
    
    ivec <- par['N0'] * exp((-par['F_full'] - par['M']) * 0:(par['nage']-1))
    
  }else if(type == "input"){
    
    ivec <- par
    
  }else{
    stop("get_init: incorrect type given")
  }
  
  return(ivec)
}
