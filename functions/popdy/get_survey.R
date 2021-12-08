#' @title Generate Survey Values
#' @description Generate survey index-at-age values
#' 
#' @param F_full Annual fishing mortality ??? number or vector?
#' @param M Annual natural mortality ??? number or vector?
#' @param N Vector of abundance-at-age (after population growth and recruitment occur)
#' @param slxF Vector of fishery selectivity-at-age
#' @param slxI Vector of survey selectivity-at-age
#' @param timeI Survey timing as a proportion of the year that has elapsed (e.g., Jul 1 survey is 0.5 and Jan 1 survey is 0)
#' @param qI Survey catchability ??? number or vector?
#' @param DecCatch A boolean, if TRUE survey catchability decreases as temperature increases, if FALSE survey catchability unaffected by temperature. 
#' @template global_Tanom
#' @template global_y
#' 
#' @return A vector of survey index-at-age
#'
#' @family managementProcedure, survey
#' 
#' @export

get_survey <- function(F_full, 
                       M, 
                       N, 
                       slxF, 
                       slxI, 
                       timeI, 
                       qI, 
                       DecCatch, 
                       Tanom, 
                       y){
  
  if(length(N) != length(slxF)){
    stop('length N must be == length selF')
  }
  
  # calculate Z
  Z <- slxF * F_full + M
  
  # Get the index
  if (DecCatch==TRUE & y>fmyearIdx){#decrease survey catchability based on temperature. It does not decrease more than half the original value. 
qI<-0.0001-(0.0000125*Tanom)
if(qI<0.00005){qI<-0.00005}
   # qI<-0.0001-(0.0000225*Tanom)
  #  if(qI<0.00001){qI<-0.00001}
  }
  
  I <- slxI * qI * N * exp(-Z * timeI)
  
  return(I)
}
