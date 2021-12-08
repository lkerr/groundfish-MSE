#' @title Get F Implementation Error
#' @description Generate implementation error for fishing mortality (F) - the actual fishing mortality is unlikely to be exactly the value recommended by management.
#' 
#' @param type A string specifying the distribution used to generate F implementation error, options are:
#' \itemize{
#'   \item{"lognormal" - Implementation error is lognormally distributed}
#' }
#' @param par A vector of parameters used to generate F implementation error, depend on specified type:
#' \itemeize{
#'   \item{If type = "lognormal", par is a number for the standard deviation parameter}
#' }
#' @param F A number for the fishing mortality recommended through the management procedure process ??? is this a vector-at-age
#' 
#' @return A number for fishing mortality with implementation error. ??? vector at age?
#' 
#' @family operatingModel
#' 
#' @export

get_ieF <- function(type, 
                    par, 
                    F){
  
  if(type == 'lognormal'){
    
    ieF <- rlnorm(1, meanlog = F, sdlog = par)
    
  }
  
  return(ieF)
}
