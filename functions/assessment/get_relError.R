

get_relError <- function(stock){
  
  
  out <- within(stock, {
  
    #### Calculate rel errors ####
    CN[y,] %*% waa[y,]     
    if(mproc[m,'ASSESSCLASS'] == 'CAA' & y > fmyearIdx-1){
      relE_SSB[y-1] <- mean(get_relE(SSBhat, get_dwindow(SSB, sty, y-1)))
      relE_CW[y-1] <- mean(get_relE(rep$sumCW, get_dwindow(sumCW, sty, y-1)))
      relE_IN[y-1] <- mean(get_relE(rep$sumIN, get_dwindow(sumIN, sty, y-1)))
      relE_qI[y-1] = get_relE(rep$log_qI, log(qI))
      relE_qC[y-1] = get_relE(rep$log_qC, log(qC))
      relE_selCs0[y-1] = get_relE(rep$log_selC[1], log(selC['s0']))
      relE_selCs1[y-1] = get_relE(rep$log_selC[2], log(selC['s1']))
      relE_ipop_mean[y-1] = get_relE(rep$log_ipop_mean, log_ipop_mean)
      relE_ipop_dev[y-1] = mean(get_relE(rep$ipop_dev, ipop_dev))
      relE_R_dev[y-1] = mean(get_relE(rep$R_dev, R_dev))
      relE_R[y-1] <- mean(get_relE(rep$R, get_dwindow(R, sty, y-1))) #AEW
      relE_F[y-1] <- mean(get_relE(rep$F_full, get_dwindow(F_full, sty, y-1))) #AEW
    } 
    
    if(mproc[m,'ASSESSCLASS'] == 'ASAP' & y > fmyearIdx-1){
      relE_SSB[y-1] <- get_relE(tail(res$SSB,1), SSB[y-1])
      relE_CW[y-1] <- get_relE(res$catch.pred[37], sumCW[y-1])
      relE_IN[y-1] <- get_relE(tail(res$index.pred$ind01,1), sumIN[y-1])
      relE_qI[y-1] <- get_relE(log(res$q.indices), log(qI))
      #relE_qC[y] <- get_relE(NA, log(qC))                           
      #relE_selCs0[y] <- get_relE(res$sel.input.mats$index.sel.ini[10,1], log(selC['s0'])) #initial not estimates
      #relE_selCs1[y] <- get_relE(res$sel.input.mats$index.sel.ini[11,1], log(selC['s1'])) #inital not estimates
      #relE_ipop_mean[y] <- get_relE(NA, log_ipop_mean)       # initial population
      #relE_ipop_dev[y] <- get_relE(NA, ipop_dev)             #
      #relE_R_dev[y] <- get_relE(tail(res$SR.resids$logR.dev,1), log(R_dev[y]))
      relE_R[y-1] <- get_relE(tail(res$SR.resids$recruits,1), R[y-1])
      relE_F[y-1] <- get_relE(tail(res$F.report,1), F_full[y-1])
    } 
  })

  return(out)
  
}





