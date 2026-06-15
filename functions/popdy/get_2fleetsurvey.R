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
#
# Tanom: temperature anomaly
#
# y: year in simulation 

get_2fleetsurvey <- function( M, N, slxI, timeI, qI, DecCatch, Tanom, y, slxC, slxR, comF_full, recF_full){
  
  if(length(N) != length(slxC)){
    stop('length N must be == length selF')
  }
  
  # calculate Z

      Z <- ((slxC * comF_full) +  (slxR * recF_full)) + M

  
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







