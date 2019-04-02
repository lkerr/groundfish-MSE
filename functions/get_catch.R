

# Equation to calculate catch based on available numbers, fishing
# mortality, selectivity and natural mortality. Just the Baranov
# catch equation.
# 
# F_full: annual fully-selected fishing mortality
# M: annual natural mortality
# N: vector of abundance by age (after growth and recruitment)
# selC: vector of fishery selectivity by age
# realizedCatchModel: realized catch model option (see set_om_parameters.R)


get_catch <- function(F_full, M, N, selC, realizedCatchModel=1){
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  } # end if
  
  # calculate Z
  Z <- selC * F_full + M
    
  # Baranov catch eqn to calculate ACL
  ACL <- (selC * F_full / Z) * N * (1 - exp(-Z))
  
  # 1 - ACL:  Direct 1:1 relationship between ACL and catch, where the catch==F==ACL
  if(realizedCatchModel==1){
    # "Convert" ACL to catch
    C<-ACL
    
    return(C)
  } # End realizedCatchModel==1 - ACL
  
  # 2 - Single-species:  Catch for a given species is modeled as a function of the ACL for that species Catch=lm(Catch~ACL)
  if(realizedCatchModel==2){
    load('data/data_processed/catchHistory/realizedCatchModels.RData')
    C<-predict(reg_cod,data.frame(ACL_cod=ACL))
    
    return(C)
  } # End realizedCatchModel==2 - Single-species
  
  # 3 - Multi-species:  Catch for a all species is modeled as a function of the ACL for all species Catch[i]=lm(Catch[N]~ACL[N])
  if(realizedCatchModel==3){
    load('data/data_processed/catchHistory/realizedCatchModels.RData')
    
    C<-predict(mvreg_cod,data.frame(ACL_cod=ACL))
    
    return(C)
  } # End realizedCatchModel==3 - Multi-species
  
  # 4 - Adv multi-species: Thorson approach to multiple species catch modeling
  if(realizedCatchModel==4){
  } # End realizedCatchModel==4 - Adv multi-species
  
  # 5 - Econ catch shares: Description needed from Min-Yang or Anna
  if(realizedCatchModel==5){} # End realizedCatchModel==5 - Econ catch shares
  
  # 6 - Econ non-tradable input control: Description needed from Min-Yang or Anna  
  if(realizedCatchModel==6){} # End realizedCatchModel==6 - Econ non-tradable

}
  