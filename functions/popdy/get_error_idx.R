#' @title Get Error Index
#' @description Return errors in an index
#' 
#' @param type A string specifying the type of error to implement (@seealso \code{\link{runSims}} oe_sumIN_typ parameter for full documentation of type)
#' @param idx A vector of index values (e.g., survey total catch)
#' @param par A vector of parameters (@seealso \code{\link{runSims}} pe_IA parameter documentation)
#' 
#' @return 
#' 
#' @family operatingModel, population, projection
#' 

#      lognormal: rlnorm(1, meanlog=log(idx) - par^2/2,
#                        sdlog = par)
#                 the -par^2/2 is the bias correction


get_error_idx <- function(type, 
                          idx, 
                          par){
     
      idxE <- rlnorm(1, meanlog = log(idx), # - par^2/2
                          sdlog = par)
      
  return(idxE)
}
