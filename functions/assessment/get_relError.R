

get_relError <- function(stock){
  
  
  out <- within(stock, {
  
    #### Calculate rel errors ####
    CN[y,] %*% waa[y,]     
    if(mproc[m,'ASSESSCLASS'] == 'CAA' & y > fmyearIdx-1){
      relE_SSB[y] <- mean(get_relE(SSBhat, get_dwindow(SSB, sty, y-1)))
      relE_CW[y] <- mean(get_relE(rep$sumCW, get_dwindow(sumCW, sty, y-1)))
      relE_IN[y] <- mean(get_relE(rep$sumIN, get_dwindow(sumIN, sty, y-1)))
      relE_qI[y] = get_relE(rep$log_qI, log(qI))
      relE_qC[y] = get_relE(rep$log_qC, log(qC))
      relE_selCs0[y] = get_relE(rep$log_selC[1], log(selC['s0']))
      relE_selCs1[y] = get_relE(rep$log_selC[2], log(selC['s1']))
      relE_ipop_mean[y] = get_relE(rep$log_ipop_mean, log_ipop_mean)
      relE_ipop_dev[y] = mean(get_relE(rep$ipop_dev, ipop_dev))
      relE_R_dev[y] = mean(get_relE(rep$R_dev, R_dev))
    } 
  })

  return(out)
  
}





