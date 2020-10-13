

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



get_survey <- function(F_full, M, N, slxF, slxI, timeI, qI, DecCatch, Tanom, y){
  
  if(length(N) != length(slxF)){
    stop('length N must be == length selF')
  }
  
  # calculate Z
  Z <- slxF * F_full + M
  
  # Get the index
  if (DecCatch==TRUE & y>fmyearIdx){
  qI<-0.0001-(0.0000125*Tanom)
  if(qI<0.00005){qI<-0.00005}
  }
  I <- slxI * qI * N * exp(-Z * timeI)
  
  return(I)
  
}







