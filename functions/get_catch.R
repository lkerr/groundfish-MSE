

# Equation to calculate catch based on available numbers, fishing
# mortality, selectivity and natural mortality. Just the Baranov
# catch equation.
# 
# F_full: annual fully-selected fishing mortality
# M: annual natural mortality
# N: vector of abundance by age (after growth and recruitment)
# selC: vector of fishery selectivity by age
# realizedCatchModel: realized catch model option (see set_om_parameters.R)


get_catch <- function(F_full, M, N, selC, realizedCatchModel){
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  } # end if
  
  # calculate Z
  Z <- selC * F_full + M
    
  # Baranov catch eqn to calculate ACL
  ACL <- (selC * F_full / Z) * N * (1 - exp(-Z))
    
  if(realizedCatchModel==1){
    # "Convert" ACL to catch
    C<-ACL
    
    return(C)
  } # End realizedCatchModel==1 - ACL
  
  if(realizedCatchModel==2){
    load("~/data/data_processed/catchHistory/realizedCatchModels.RData")
  } # End realizedCatchModel==2 - Single-species
  
  if(realizedCatchModel==3){
    load("~/data/data_processed/catchHistory/realizedCatchModels.RData")
  } # End realizedCatchModel==3 - Multi-species
  
  if(realizedCatchModel==4){
  } # End realizedCatchModel==4 - Adv multi-species
  
  if(realizedCatchModel==5){} # End realizedCatchModel==5 - Econ catch shares
  
  if(realizedCatchModel==6){} # End realizedCatchModel==6 - Econ non-tradable

}
  