

# Equation to calculate catch based on available numbers, fishing
# mortality, selectivity and natural mortality. Just the Baranov
# catch equation.
# 
# F_full: annual fully-selected fishing mortality
# M: annual natural mortality
# N: vector of abundance by age (after growth and recruitment)
# selC: vector of fishery selectivity by age



get_catch <- function(F_full, M, N, selC){
  
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  }
  
  # calculate Z
  Z <- selC * F_full + M
  
  # Baranov catch eqn
  C <- (selC * F_full / Z) * N * (1 - exp(-Z))
  
  return(C)
  
}




