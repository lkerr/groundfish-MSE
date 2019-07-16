

get_indexData <- function(stock){

  within(stock, {

    sumCW[y-1] <- CN[y-1,] %*% waa[y-1,]    # (dot product)
    
    paaCN[y-1,] <- (CN[y-1,]) / sum(CN[y-1,])
    
    # calculate the predicted survey index in year y and the predicted
    # survey proportions-at-age
    IN[y-1,] <- get_survey(F_full=F_full[y-1], M=M, N=J1N[y-1,], slxC[y-1,], 
                         slxI=selI, timeI=timeI, qI=qI)
    sumIN[y-1] <- sum(IN[y-1,])
    sumIW[y-1] <- IN[y-1,] %*% waa[y-1,]
    
    paaIN[y-1,] <- IN[y-1,] / sum(IN[y-1,])
    
    # calculate effort based on catchability and the implemented fishing
    # mortality. Effort not typically derived ... could go the other way
    # around and implement E as a policy and calculate F.
    effort[y-1] <- F_full[y-1] / qC
    obs_effort[y-1] <- get_error_idx(type=oe_effort_typ, idx=effort[y-1], 
                                     par=oe_effort)
    # Get observation error data for the assessment model
    obs_sumCW[y-1] <- get_error_idx(type=oe_sumCW_typ, 
                                    idx=sumCW[y-1] * ob_sumCW, 
                                    par=oe_sumCW)
    obs_paaCN[y-1,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y-1,], 
                                     par=oe_paaCN)
    obs_sumIN[y-1] <- get_error_idx(type=oe_sumIN_typ, 
                                    idx=sumIN[y-1] * ob_sumIN, 
                                    par=oe_sumIN)
    
    # Observed index by weight is a function of the observed index and the
    # true paa. This preserves the fact that the multinomial paa and the
    # lognormal numbers-at-age are separate processes (which is consistent with
    # most assessment models)
    obs_sumIW[y-1] <- (obs_sumIN[y-1] * paaIN[y-1,]) %*% waa[y-1,]
    obs_paaIN[y-1,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y-1,], 
                                     par=oe_paaIN)
    
  })

  
}
      