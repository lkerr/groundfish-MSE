

# Equation to calculate catch based on available numbers, fishing
# mortality, selectivity and natural mortality. Just the Baranov
# catch equation.
#
# type: realized catch model option (see mprocOptions.md)
# F_full: annual fully-selected fishing mortality
# M: annual natural mortality
# N: vector of abundance by age (after growth and recruitment)
# selC: vector of fishery selectivity by age

get_catch <- function(type, F_full, M, N, selC){
  if(length(N) != length(selC)){
    stop('length N must be == length sel')
  } # end if
  
  # calculate Z
  Z <- selC * F_full + M
    
  # Baranov catch eqn to calculate ACL
  ACL <- (selC * F_full / Z) * N * (1 - exp(-Z))
  
  # 1 - ACL:  Direct 1:1 relationship between ACL and catch, where the catch==F==ACL
  if(type==1){
    # "Convert" ACL to catch
    C<-ACL
    
    return(C)
  } # End type==1 - ACL
  
  # 2 - Single-species:  Catch for a given species is modeled as a function of the ACL for that species Catch=lm(Catch~ACL)
  if(type==2){
    load('data/data_processed/catchHistory/realizedCatchModels.RData')
    C<-predict(reg_cod,data.frame(ACL_cod=ACL))
    
    return(C)
  } # End type==2 - Single-species
  
  # 3 - Multi-species:  Catch for a all species is modeled as a function of the ACL for all species Catch[i]=lm(Catch[N]~ACL[N])
  if(type==3){
    load('data/data_processed/catchHistory/realizedCatchModels.RData')
    
    C<-predict(mvreg_cod,data.frame(ACL_cod=ACL))
    
    return(C)
  } # End type==3 - Multi-species
  
  # 4 - Adv multi-species: Thorson approach to multiple species catch modeling
  if(type==4){
  } # End type==4 - Adv multi-species
  
  # 5 - Econ catch shares: Description needed from Min-Yang or Anna
  if(type==5){} # End type==5 - Econ catch shares
  
  # 6 - Econ non-tradable input control: Description needed from Min-Yang or Anna  
  if(type==6){} # End type==6 - Econ non-tradable

}
  