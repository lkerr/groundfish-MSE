

# For simplicity, have one list (oacomp) that goes through comparing
# the assessment model results with the true values and then have
# another object that will just hold the values themselves.  Makes
# things easier for analysis of results

# y2 <- y - (ncaayear + fyear + nburn)


# oacomp$sumCW[r,m,y2,,'val'] <- get_dwindow(sumCW, sty, y)
# oacomp$sumCW[r,m,y2,,'caahat'] <- rep$sumCW
# 
# oacomp$paaCN[r,m,y2,,,'val'] <- get_dwindow(paaCN, sty, y)
# oacomp$paaCN[r,m,y2,,,'caahat'] <- rep$paaCN
# 
# oacomp$sumIN[r,m,y2,,'val'] <- get_dwindow(sumIN, sty, y)
# oacomp$sumIN[r,m,y2,,'caahat'] <- rep$sumIN
# 
# oacomp$paaIN[r,m,y2,,,'val'] <- get_dwindow(paaIN, sty, y)
# oacomp$paaIN[r,m,y2,,,'caahat'] <- rep$paaIN
# 
# # oacomp$effort[r,m,y2,,'val'] <- get_dwindow(effort, sty, y)
# # oacomp$effort[r,m,y2,,'caahat'] <- -99
# # 
# # oacomp$laa[r,m,y2,,,'val'] <- get_dwindow(laa, sty, y)
# # oacomp$laa[r,m,y2,,,'caahat'] <- rep$laa
# # 
# # oacomp$waa[r,m,y2,,,'val'] <- get_dwindow(waa, sty, y)
# # oacomp$waa[r,m,y2,,,'caahat'] <- rep$waa
# # 
# # oacomp$oe_paaCN[r,m,y2,'val'] <- oe_paaCN
# # oacomp$oe_paaCN[r,m,y2,'caahat'] <- rep$oe_paaCN
# # 
# # oacomp$oe_paaIN[r,m,y2,'val'] <- oe_paaIN
# # oacomp$oe_paaIN[r,m,y2,'caahat'] <- rep$oe_paaIN
# # 
# # oacomp$M[r,m,y2,,,'val'] <- matrix(data=M, nrow=ncaayear, ncol=nage)
# # oacomp$M[r,m,y2,,,'caahat'] <- rep$M
# # 
# # oacomp$R_dev[r,m,y2,,'val'] <- R_dev
# # oacomp$R_dev[r,m,y2,,'caahat'] <- rep$R_dev
# # 
# # oacomp$log_ipop_mean[r,m,y2,'val'] <- log_ipop_mean
# # oacomp$log_ipop_mean[r,m,y2,'caahat'] <- rep$log_ipop_mean
# # 
# # oacomp$ipop_dev[r,m,y2,,'val'] <- ipop_dev
# # oacomp$ipop_dev[r,m,y2,,'caahat'] <- rep$ipop_dev
# # 
# # oacomp$oe_sumCW[r,m,y2,'val'] <- oe_sumCW
# # oacomp$oe_sumCW[r,m,y2,'caahat'] <- rep$oe_sumCW
# # 
# # oacomp$oe_sumIN[r,m,y2,'val'] <- oe_sumIN
# # oacomp$oe_sumIN[r,m,y2,'caahat'] <- rep$oe_sumIN
# # 
# # oacomp$pe_R[r,m,y2,'val'] <- pe_R
# # oacomp$pe_R[r,m,y2,'caahat'] <- pe_R
# # 
# # oacomp$selC[r,m,y2,,'val'] <- selC
# # oacomp$selC[r,m,y2,,'caahat'] <- rep$selC
# 
# oacomp$qC[r,m,y2,'val'] <- qC
# oacomp$qC[r,m,y2,'caahat'] <- rep$qC
# 
# # oacomp$qI[r,m,y2,'val'] <- qI
# # oacomp$qI[r,m,y2,'caahat'] <- rep$qI
# # 
# # oacomp$selI[r,m,y2,,'val'] <- -99
# # oacomp$selI[r,m,y2,,'caahat'] <- -99
# 
# oacomp$slxC[r,m,y2,,,'val'] <- get_dwindow(slxC, sty, y)
# oacomp$slxC[r,m,y2,,,'caahat'] <- rep$slxC
# 
# oacomp$F_full[r,m,y2,,'val'] <- get_dwindow(F_full, sty, y)
# oacomp$F_full[r,m,y2,,'caahat'] <- rep$F_full
# 
# oacomp$F[r,m,y2,,,'val'] <- t(sapply(1:ncaayear, function(i){
#                                  slxC[i,] * get_dwindow(F_full, sty, y)[i]
#                             }))
# oacomp$F[r,m,y2,,,'caahat'] <- rep$F
# 
# # oacomp$Z[r,m,y2,,,'val'] <- get_dwindow(Z, sty, y)
# # oacomp$Z[r,m,y2,,,'caahat'] <- rep$Z
# 
# oacomp$R[r,m,y2,,'val'] <- get_dwindow(R, sty, y)
# oacomp$R[r,m,y2,,'val'] <- rep$R
# 
# # oacomp$J1N[r,m,y2,,,'val'] <- get_dwindow(J1N, sty, y)
# # oacomp$J1N[r,m,y2,,,'caahat'] <- rep$J1N
# # 
# # oacomp$CN[r,m,y2,,,'val'] <- get_dwindow(CN, sty, y)
# # oacomp$CN[r,m,y2,,,'caahat'] <- rep$CN
# 

# oacomp$SSB[r,m,y2,,'val'] <- get_dwindow(SSB, sty, y)
# oacomp$SSB[r,m,y2,,'caahat'] <- SSBhat
# 
# # oacomp$IN[r,m,y2,,,'val'] <- get_dwindow(IN, sty, y)
# # oacomp$IN[r,m,y2,,,'caahat'] <- rep$IN
# # 
# # oacomp$NLL[r,m,y2,'val'] <- -99
# # oacomp$NLL[r,m,y2,'caahat'] <- rep$NLL
# # 
# # oacomp$NLL_sumCW[r,m,y2,'val'] <- -99
# # oacomp$NLL_sumCW[r,m,y2,'caahat'] <- rep$NLL_sumCW
# # 
# # oacomp$NLL_sumIN[r,m,y2,'val'] <- -99
# # oacomp$NLL_sumIN[r,m,y2,'caahat'] <- rep$NLL_sumIN
# # 
# # oacomp$NLL_R_dev[r,m,y2,'val'] <- -99
# # oacomp$NLL_R_dev[r,m,y2,'caahat'] <- rep$NLL_R_dev
# # 
# # oacomp$NLL_paaCN[r,m,y2,'val'] <- -99
# # oacomp$NLL_paaCN[r,m,y2,'caahat'] <- rep$NLL_paaCN
# # 
# # oacomp$NLL_paaIN[r,m,y2,'val'] <- -99
# # oacomp$NLL_paaIN[r,m,y2,'caahat'] <- rep$NLL_paaIN



## Here start filling the simpler arrays with just the OM values
## Note that nomyear is a function of "rburn" in the set_om_parameters.R
## file. rburn ensures that you are starting at least part-way into the
## management time-period so you can see the response. It is set pretty
## arbitrarily though.


get_fillRepArrays <- function(stock){

  
  out <- within(stock, {
      
    omval$SSB[r,m,] <- SSB
    omval$R[r,m,] <- R
    omval$F_full[r,m,] <- F_full
    omval$sumCW[r,m,] <- sumCW
    omval$OFdStatus[r,m,] <- OFdStatus
    omval$mxGradCAA[r,m,] <- mxGradCAA
    omval$F_fullAdvice[r,m,] <- F_fullAdvice #AEW
    omval$ACL[r,m,] <- ACL #AEW
    omval$OFgStatus[r,m,] <- OFgStatus #AEW
    omval$SSB_cur[r,m,] <- SSB_cur #AEW
    omval$natM[r,m,] <- natM #AEW
    
    # annPercentChange not true vector -- just repeated values. This needs
    # to be calculated after the run so that the appropriate time windows
    # can be used.
    omval$annPercentChange[r,m,] <- NA # placeholder -- calculated later
    meanSizeCN <- sapply(1:nrow(CN), 
                         function(x) laa[x,] %*% paaCN[x,])
    omval$meanSizeCN[r,m,] <- meanSizeCN
    meanSizeIN <- sapply(1:nrow(CN), 
                         function(x) laa[x,] %*% paaIN[x,])
    omval$meanSizeIN[r,m,] <- meanSizeIN
    omval$FPROXY[r,m,] <- RPmat[,1]
    omval$SSBPROXY[r,m,] <- RPmat[,2]
    if(y == nyear){
      # Determine whether additional years should be added on to the
      # beginning of the series
      if(nyear > length(cmip_dwn$YEAR)){
        nprologueY <- nyear - length(cmip_dwn$YEAR)
        prologueY <- (cmip_dwn$YEAR[1]-nprologueY):(cmip_dwn$YEAR[1]-1)
        yrs <- c(prologueY, cmip_dwn$YEAR)
      # If no additional years needed then just take them from the years
      # time series.
      }else{
        yrs <- rev(rev(cmip_dwn$YEAR)[1:nyear])
      }
      omval$YEAR <- yrs
    }
    
    
    # Assessment model diagnostics ... -1 gives 1 NA. Will change when I get
    # around to reporting all years for all metrics.
    omval$relE_qI[r,m,] <- relE_qI
    omval$relE_qC[r,m,] <- relE_qC
    omval$relE_selCs0[r,m,] <- relE_selCs0
    omval$relE_selCs1[r,m,] <- relE_selCs1
    omval$relE_ipop_mean[r,m,] <- relE_ipop_mean
    omval$relE_ipop_dev[r,m,] <- relE_ipop_dev
    omval$relE_R_dev[r,m,] <- relE_R_dev
    omval$relE_SSB[r,m,] <- relE_SSB
    omval$relE_CW[r,m,] <- relE_CW
    omval$relE_IN[r,m,] <- relE_IN
    omval$relE_R[r,m,] <- relE_R #AEW
    omval$relE_F[r,m,] <- relE_F #AEW
    omval$conv_rate[r,m,]<-conv_rate #MDM
    omval$Mohns_Rho[r,m,]<-Mohns_Rho #MDM
    if (y == nyear){
    omval$relTermE_SSB[r,m,] <- relTermE_SSB #MDM
    omval$relTermE_CW[r,m,] <- relTermE_CW #MDM
    omval$relTermE_IN[r,m,] <- relTermE_IN #MDM
    omval$relTermE_qI[r,m,] <- relTermE_qI #MDM
    omval$relTermE_R[r,m,] <- relTermE_R #MDM
    omval$relTermE_F[r,m,] <- relTermE_F #MDM
    }
  })

  return(out)
  
}

