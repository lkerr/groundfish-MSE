#' @title Return index errors 
#'
#' @param type String describing type of error implemented. Options include:
#' \itemize{
#'  \item{"lognorm" = lognormal errors, details below}
#'  \item{''}
#' }
#' @param idx Vector of index values (e.g., survey total catch)
#' @param par Vector of parameters
#'      
#'      lognormal: rlnorm(1, meanlog=log(idx) - par^2/2,
#'                        sdlog = par)
#'                 the -par^2/2 is the bias correction
#'                 
#' @return idxE - the index errors


get_error_idx <- function(type, idx, par){
     
      idxE <- rlnorm(1, meanlog = log(idx), # - par^2/2
                          sdlog = par)
  return(idxE)
  
}



