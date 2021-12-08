#' @title Generate Log-Scale Random Walk Devs
#' @description Recreate random walk deviations on a log scale (e.g. generate for recruitment deviations so you know what the true values are in the assessment model if the assessment is coded as a random walk). The returned vector will have length(x) - 1 elements.
#' 
#' @param x A vector for which a random walk should be generated
#'
#' @return A vector of log-scale random walk deviations, length of return is 1 less than input vector, x. 
#' 
#' @family operatingModel
#' 
#' @export

get_RWdevs <- function(x){
  
  lRWdev <- numeric(length(x)-1)
  
  for(i in 2:length(x)){
    lRWdev[i-1] <- log(x[i] / x[i-1])
  }
  
  return(lRWdev)
  
}
