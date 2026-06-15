

# Equation to calculate catch based on available numbers, fishing
# mortality, selectivity and natural mortality. Just the Baranov
# catch equation.
# 
# F_full: annual fully-selected fishing mortality
# M: annual natural mortality
# N: vector of abundance by age (after growth and recruitment)
# selC: vector of fishery selectivity by age



get_2fcatch <- function(comF_full, recF_full, M, N, selC, selR, type){
  
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  }
  
  # calculate Z
  Z <- ((selC * recF_full) + (selC * comF_full)) + M
  
  # Baranov catch eqn
  
  if(type == "com"){
    
    C <- (selC * comF_full / Z) * N * (1 - exp(-Z))
    
  }else if(type == "rec"){
    
    C <- (selR * recF_full / Z) * N * (1 - exp(-Z))
    
  }else if(type == "both"){
    
    C <- ((selC * comF_full + selR * recF_full) / Z) * N * (1 - exp(-Z))
  
    }else{
      stop('provide catch type "rec" or "comm"')
    }
  
  return(C)
  
}




