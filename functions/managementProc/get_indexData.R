

get_indexData <- function(stock){

  within(stock, {
   
    sumCW[y] <- CN[y,] %*% waa[y,]    # (dot product)
    
    paaCN[y,] <- (CN[y,]) / sum(CN[y,])
   
    # calculate the predicted survey index in year y and the predicted
    # survey proportions-at-age

    IN[y,] <- get_survey(F_full=F_full[y], M=natM[y], N=J1N[y,], slxC[y,], 
                           slxI=selI, timeI=timeI, qI=qI)
    sumIN[y] <- sum(IN[y,])
    sumIW[y] <- IN[y,] %*% waa[y,]
    
    paaIN[y,] <- IN[y,] / sum(IN[y,])
    
    # calculate effort based on catchability and the implemented fishing
    # mortality. Effort not typically derived ... could go the other way
    # around and implement E as a policy and calculate F.

    effort[y] <- F_full[y] / qC
    obs_effort[y] <- get_error_idx(type=oe_effort_typ, idx=effort[y], 
                                     par=oe_effort,switch=FALSE)
    # Get observation error data for the assessment model
    # change point where bias in catch is applied in 2015 before the start of
    # the projection period
     if (y < c(fmyearIdx)){
     obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ,
                                     idx=sumCW[y],
                                     par=oe_sumCW,switch=FALSE)
     }
     if (y >= (fmyearIdx)){
    obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ, 
                                    idx=sumCW[y] * ob_sumCW, 
                                    par=oe_sumCW,switch=FALSE)
     }
    
    
    obs_paaCN[y,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y,], 
                                     par=oe_paaCN,switch=FALSE)
    
    if (obsbias==TRUE & R[y]>400000000){
    obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, 
                                    idx=sumIN[y] * ob_sumIN, 
                                    par=oe_sumIN,switch=TRUE)}
    else{obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, 
                                          idx=sumIN[y] * ob_sumIN, 
                                          par=oe_sumIN,switch=FALSE)}
    
    # Observed index by weight is a function of the observed index and the
    # true paa. This preserves the fact that the multinomial paa and the
    # lognormal numbers-at-age are separate processes (which is consistent with
    # most assessment models)
    obs_sumIW[y] <- (obs_sumIN[y] * paaIN[y,]) %*% waa[y,]
    if (obsbias==TRUE & R[y]>400000000){
    obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                     par=oe_paaIN,switch=TRUE)}
    else{obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                     par=oe_paaIN,switch=FALSE)}

  })

  
}
      