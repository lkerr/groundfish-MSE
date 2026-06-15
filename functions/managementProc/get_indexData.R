#Function to get survey index 
get_indexData <- function(stock){
  
  within(stock, {
    
    
    
    if(nfleet == 2){
      sumcomCW[y] <- comCN[y,] %*% waa[y,]  # dot product
      sumrecCW[y] <- recCN[y,] %*% waa[y,]  # dot product
      
      paacomCN[y,] <- (comCN[y,]) / sum(comCN[y,])
      paarecCN[y,] <- (recCN[y,]) / sum(recCN[y,])
      
      sumCW[y] <- sumcomCW[y] + sumrecCW[y]
      
      paaCN[y,] <- (CN[y,]) / sum(CN[y,])
      
      # calculate the predicted survey index in year y 
      
      IN[y,] <- get_2fleetsurvey(comF_full=comF_full[y], 
                                 recF_full=recF_full[y], 
                                 M=natM[y], 
                                 N=J1N[y,], 
                                 slxC[y,],
                                 slxR[y,], 
                                 slxI=selI, timeI=timeI, qI=qI, 
                                 DecCatch=DecCatch, Tanom=Tanom[y],y=y)
      
    }else{
      
      sumCW[y] <- CN[y,] %*% waa[y,]  # dot product
      
      paaCN[y,] <- (CN[y,]) / sum(CN[y,])    
      
      # calculate the predicted survey index in year y 
      IN[y,] <- get_survey(F_full=F_full[y], M=natM[y], N=J1N[y,], slxC[y,], 
                           slxI=selI, timeI=timeI, qI=qI, 
                           DecCatch=DecCatch, Tanom=Tanom[y],y=y)
    }
    
    
    # calculate the predicted survey proportions-at-age
    sumIN[y] <- sum(IN[y,])
    sumIW[y] <- IN[y,] %*% waa[y,]
    
    paaIN[y,] <- IN[y,] / sum(IN[y,])
    
    # calculate effort based on catchability and the implemented fishing
    # mortality. Effort not typically derived ... could go the other way
    # around and implement E as a policy and calculate F.
    
    if(nfleet == 2){
      comeffort[y] <- comF_full[y] / qC
      obs_comeffort[y] <- get_error_idx(type=oe_comeffort_typ, idx=comeffort[y], 
                                        par=oe_comeffort) 
      receffort[y] <- recF_full[y] / qR
      obs_receffort[y] <- get_error_idx(type=oe_receffort_typ, idx=receffort[y], 
                                        par=oe_receffort) 
    }else{
      effort[y] <- F_full[y] / qC
      obs_effort[y] <- get_error_idx(type=oe_effort_typ, idx=effort[y], 
                                     par=oe_effort)  
    }
    
    
    # Get observation error data for the assessment model
    if (y < c(fmyearIdx)){
      
      if(nfleet == 2){
        
        obs_sumcomCW[y] <- sumcomCW[y]
        obs_sumrecCW[y] <- sumrecCW[y]
        
      }else{
        obs_sumCW[y] <- sumCW[y]
        
      }
      
      
    }
    
    if (y >= (fmyearIdx)){
      
      if(nfleet ==2){
        
        obs_sumcomCW[y] <- get_error_idx(type=oe_sumcomCW_typ, 
                                         idx=sumcomCW[y] * ob_sumcomCW, 
                                         par=oe_sumcomCW)
        
        obs_sumrecCW[y] <-  get_error_idx(type=oe_sumrecCW_typ, 
                                          idx=sumrecCW[y] * ob_sumrecCW, 
                                          par=oe_sumrecCW)
        
        obs_sumCW[y] <- obs_sumcomCW[y] + obs_sumrecCW[y] 
        
        
        
        

        
      }else{
        obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ, 
                                      idx=sumCW[y] * ob_sumCW, 
                                      par=oe_sumCW)
        

        
        
        
      }
      
    }

  
  
    
    if(nfleet == 2){
      obs_paacomCN[y,] <- get_error_paa(type=oe_paacomCN_typ, paa=paacomCN[y,], 
                                        par=oe_paacomCN)
      obs_paarecCN[y,] <- get_error_paa(type=oe_reccomCN_typ, paa=paarecCN[y,], 
                                        par=oe_paarecCN)
    }else{
      obs_paaCN[y,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y,], 
                                     par=oe_paaCN)
    }
    
    
    
    ### adding in missing survey data probabalistically
    ## only for the observed index values, not "true"
    
    
    if(mproc[m,'MissingIdx'] == 'TRUE' & y >= (fmyearIdx + 10) & y < (fmyearIdx + 20)){ # 2nd 10 years of management period w/ probabalistic missing data
      
      prob <- rbinom(1, 1, 0.4) # 1 = 40% chance of occuring
      
      if(prob == 1){
        obs_sumIN[y] <- -999
        obs_sumIW[y] <- NA
        obs_paaIN[y,] <- NA
      }
      
      if(prob == 0){
        
        obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, 
                                      idx=sumIN[y] * ob_sumIN, 
                                      par=oe_sumIN)
        
        # Observed index by weight is a function of the observed index and the
        # true proportions at age. This preserves the fact that the multinomial proportions at age
        # and the lognormal numbers-at-age are separate processes (which is consistent with
        # most assessment models)
        obs_sumIW[y] <- (obs_sumIN[y] * paaIN[y,]) %*% waa[y,]
        obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                       par=oe_paaIN)
      }
    }else{
      

      obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, 
                                    idx=sumIN[y] * ob_sumIN, 
                                    par=oe_sumIN)
      
      # Observed index by weight is a function of the observed index and the
      # true proportions at age. This preserves the fact that the multinomial proportions at age
      # and the lognormal numbers-at-age are separate processes (which is consistent with
      # most assessment models)
      obs_sumIW[y] <- (obs_sumIN[y] * paaIN[y,]) %*% waa[y,]
      
      obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                     par=oe_paaIN)
      
    }

    
    
  })
}
  
  
  
  
  
  
        

