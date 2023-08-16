# function that returns survey index-at-age values
# 
# F_full: annual fishing mortality
# 
# M: annual natural mortality
# 
# N: vector of abundance by age (after growth and recruitment)
# 
# selF: vector of fishery selectivity by age
# 
# selI: vector of survey selectivity by age
# 
# timeI: survey timing as a proportion of the year that has elapsed
#        (e.g., Jul 1 survey is 0.5 and Jan 1 survey is 0)
#        
# qI: survey catchability
#
# DecCatch: switch for if survey catchability decreases over time/temperature or not. If set to TRUE, survey catchability 
#decreases at temperature increases. 
#' @param q_settings A string indicating how catchability should be adjusted, default = FALSE (no adjustment):
#' \itemize{
#'   \item("FALSE" = Default setting makes no adjustment to survey catchability)
#'   \item("DecCatch" = Previously the name of the argument used to adjust catchability, this option adjusts q to decrease with temperature (Tanom))
#'   \item("SDM_sims" = Adjust survey catchability based on SDM results)
#' }
#' @param qI Index catchability, default pulled from stock parameter files (in get_indexData) but may be adjusted here
# Tanom: temperature anomaly
#
# y: year in simulation 
#' @return A list including I the survey index and qI_rev the revised catchability

get_survey <- function(F_full, M, N, slxF, slxI, timeI, qI, q_settings = NULL, Tanom, y){
  
  if(length(N) != length(slxF)){
    stop('length N must be == length selF')
  }
  
  # calculate Z
  Z <- slxF * F_full + M
  
  # Get the index
  if(q_settings == FALSE | y<=fmyearIdx){
    qI_rev <- qI # No adjustment made if q_settings == FALSE or if year is before fmyearIdx
    
  } else if (q_settings == "DecCatch" & y>fmyearIdx){#decrease survey catchability based on temperature. It does not decrease more than half the original value. 
    qI_rev <-0.0001-(0.0000125*Tanom)
    # qI<-0.0001-(0.0000225*Tanom)
    #  if(qI<0.00001){qI<-0.00001}
    if(qI_rev<0.00005){qI_rev<-0.00005} # Don't let catchability be 0
    
  } else if(q_settings == "SDM_sims" & y>fmyearIdx){
    qI_rev <- qI-(SDManom[which(SDManom$Year == (fmyear+y-fmyearIdx-1)), "percentChange"]) # Percent change of anomaly relative to full time series (1985-2100) mean used to adjust survey q (fmyear+y-fmyearIdx-1 so fmyear is first year matched)
    if(qI_rev<0.00001){qI_rev<-0.00001} # Don't let catchability be 0
  } else if (q_settings %in% c("FALSE", "DecCatch", "SDM_sims") == FALSE){
    warning("q_settings does not exist, check spelling in stock parameter file, for 'SDM_sims' option check that Load_SDM_MSE_settings.R is sourced in runSim()")
  }

  I <- slxI * qI_rev * N * exp(-Z * timeI)
  
  return(list(I=I, qI_rev=qI_rev))
  
}







