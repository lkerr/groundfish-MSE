#' @title Get Fishing Mortality 
#' @description Calculate fishing mortality given a catch biomass. Assumes known numbers-at-age, selectivity-at-age, natural mortality and weight-at-age. True values are used here rather than any sort of estimates involving noise because all we're trying to do is to link a catch biomass to what would be the actual corresponding F so that we can embed the planB approach into the rest of the simulation. ??? check that this always uses the true values (e.g. in projections), maybe update to say OM rather than true
#'
#' @param x The true catch weight for which the corresponding F is calculated ??? check a vector?
#' @param Nv A vector of true numbers-at-age in the population
#' @param slxCv A vector of the true selectivity-at-age in the population
#' @param M A number describing the true natural mortality rate
#' @param waav A vector of the true weight-at-age in the population
#' 
#' @return 
#' 
#' @family operatingModel, population, projection
#' 

get_F <- function(x, 
                  Nv, 
                  slxCv, 
                  M, 
                  waav){
  
  # Function to calculate the difference between the true catch weight (x)
  # and the catch weight calculated assuming a value of F.
  opt <- try(optimize(getCW, interval=c(-10, 5),slxCv,M,Nv,waav,x))
  
  return(exp(opt$minimum))
}
