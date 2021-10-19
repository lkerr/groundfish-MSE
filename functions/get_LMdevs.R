#' @title Generate deviations from log-scale mean
#' @description Generate deviations from log-scale mean of a vector, has same functionality as a dev vector in admb
#' 
#' @param x A vector (in arithmetic scale) for which deviations should be generated
#'  
#' @return: A list including:
#' \itemize{
#'   \item{lmean - A number for the log-scale mean ??? check this is a number}
#'   \item{lLMdevs - A vector of log-scale deviations}
#' }
#' 
#' @family ???
#' 

get_LMdevs <- function(x){
  
  lmean <- log(mean(x))
  lLMdevs <- log(x) - lmean
  
  return(list(lmean=lmean, lLMdevs=lLMdevs))
}


