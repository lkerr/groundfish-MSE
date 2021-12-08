#' @title Calculate Catch-At-Age
#' @description Calculate catch-at-age using the Baranov catch equation, available numbers-at-age, F, selectivity, and M
#' 
#' @param F_full A number for annual fully-selected fishing mortality ??? make sure not a vector
#' @param M A number for annual natural mortality ??? or a vector /???
#' @param N A vector of abundance-at-age (after growth and recruitment)
#' @param selC A vector of fishery selectivity-at-age
#' 
#' @return A vector of catch-at-age.
#' 
#' @family 
#' 
#' @export

get_catch <- function(F_full, 
                      M, 
                      N, 
                      selC){
  
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  }
  
  # calculate Z
  Z <- selC * F_full + M
  
  # Baranov catch eqn
  C <- (selC * F_full / Z) * N * (1 - exp(-Z))
  
  return(C)
}
