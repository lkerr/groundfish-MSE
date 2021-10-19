#' @title Assess catch stability
#' @description Assess catch stability per the methods of Dichmont et al. ??? year??? Fisheries Res 81:235-245, excluding accounting for discount rate. Stability represented as the percent change in landed catches from year-to-year.
#'
#' @param x A vector of catch numbers.
#' 
#' @return A proportion between 0 and 1??? check how this is used and that this is bounded by 0/1
#' 
#' @family ???
#' 
#' @examples 
#' get_stability(rnorm(10000, 100, 2))
#' get_stability(rnorm(10000, 100, 12))
#' 

get_stability <- function(x){
  
  ny <- length(x)
  num <- sum(abs(x[2:ny] - x[1:(ny-1)]), na.rm=TRUE)
  den <- sum(x[2:ny], na.rm=TRUE)
  
  return(num / den)
}
