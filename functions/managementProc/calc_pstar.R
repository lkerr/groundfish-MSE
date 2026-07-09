#function to calculate P* 
# Can use biomass-based algorithm to emulate MAMFC approach, risk policy-informed, or user-specified


calc_pstar = function(relB, parmgt, rp)

{

###### MAFMC biomass-based approach to setting P*. HOLD OVER: NEED TO UPDATE/REVISE.
  if(tolower(parmgt$PSTAR) == "mafmc"){
    maxp <- 0.4
    if(relB>=1) #at asymptote
  {
    P = maxp
  }
  else if(relB<=0.1)
  {
    P = 0.0
  }
  else
  {
    slope <- (maxp)/(1-0.1)
    inter <- maxp-slope
    P = inter+slope*relB
  }
  }
  
##### Risk Policy informed P*
  if(tolower(parmgt$PSTAR) == "riskpolicy") {
    P = rp$pstar_rp_dynamic
  }
  
##### Fixed, user-specified P* set in mproc
  if(is.numeric(parmgt$PSTAR)) {
    P = parmgt$PSTAR
  }
  
  return(P)
}