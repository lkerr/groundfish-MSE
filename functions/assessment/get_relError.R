

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
      relE_R[y-1] <- mean(get_relE(rep$R, get_dwindow(R/caaInScalar, sty, y-1)))  #AEW
      relE_F[y-1] <- mean(get_relE(rep$F_full, get_dwindow(F_full, sty, y-1))) #AEW
    }

    if(mproc[m,'ASSESSCLASS'] == 'ASAP' & y > fmyearIdx-1){
      # terminal year
      # relE_SSB[y-1] <- get_relE(tail(res$SSB,1), SSB[y])
      # relE_CW[y-1] <- get_relE(res$catch.pred[37], sumCW[y-1])
      # relE_IN[y-1] <- get_relE(tail(res$index.pred$ind01,1), sumIN[y-1])
      # relE_qI[y-1] <- get_relE(log(res$q.indices), log(qI))
      # relE_R[y-1] <- get_relE(tail(res$SR.resids$recruits,1), R[y-1])

      # average over each assessment time series
      if ((y-fmyearIdx) %% mproc[m,'AssessFreq'] == 0){
      relE_SSB[y-1] <- mean(get_relE(res$SSB, SSB[132:(y-1)]))
      relE_CW[y-1] <- mean(get_relE(res$catch.pred, sumCW[132:(y-1)]))
      relE_IN[y-1] <- mean(get_relE(res$index.pred$ind01, sumIN[132:(y-1)]))
      #relE_qI[y-1] <- get_relE(log(res$q.indices), log(qI))
      relE_R[y-1] <- mean(get_relE(res$N.age[,1], R[132:(y-1)]))
      relE_F[y-1] <- mean(get_relE(res$F.report, F_full[132:(y-1)]))

      }
    }

  })

  return(out)

}
