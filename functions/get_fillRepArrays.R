# For simplicity, have one list that goes through comparing
# the assessment model results with the true values and then have
# another object that will just hold the values themselves.  Makes
# things easier for analysis of results

## Filling the simpler arrays with just the OM values
## Note that nomyear is a function of "rburn" in the set_om_parameters.R
## file. rburn ensures that you are starting at least part-way into the
## management time-period so you can see the response. It is set pretty
## arbitrarily though.

get_fillRepArrays <- function(stock,r,y){
m<-1
  out <- within(stock, {
    omval$N <- rowSums(J1N)
    omval$SSB <- SSB
    omval$R <- R
    omval$F_full <- F_full
    omval$sumCW <- sumCW
    omval$F_fullAdvice <- F_fullAdvice #AEW
    omval$ACL <- ACL #AEW
    omval$natM <- natM #AEW
    
    # annPercentChange not true vector -- just repeated values. This needs
    # to be calculated after the run so that the appropriate time windows
    # can be used.
    
    omval$annPercentChange <- NA # placeholder -- calculated later
    meanSizeCN <- sapply(1:nrow(CN), 
                         function(x) laa[x,] %*% paaCN[x,])
    omval$meanSizeCN <- meanSizeCN
    meanSizeIN <- sapply(1:nrow(CN), 
                         function(x) laa[x,] %*% paaIN[x,])
    omval$meanSizeIN <- meanSizeIN
    omval$FPROXY[y] <- RPmat[y,1]
    omval$SSBPROXY[y] <- RPmat[y,2]
    omval$FPROXYT[y] <- RPmat[y,3]
    omval$SSBPROXYT[y] <- RPmat[y,4]
    
    omval$SSBRATIO[y] <- stock$res$SSB[length(stock$res$SSB)]/RPmat[,2][y]
    if(mproc[m,'rhoadjust'] == 'TRUE' & y>fmyearIdx & Mohns_Rho_SSB[y]>0.15){
      omval$FRATIO[r,m,y] <- (stock$res$F.report[length(stock$res$F.report)]/(Mohns_Rho_F[y]+1))/RPmat[,1][y]
      omval$SSBRATIO[r,m,y] <-(stock$res$SSB[length(stock$res$SSB)]/(Mohns_Rho_SSB[y]+1))/RPmat[,2][y]
    }
    omval$FRATIOT[y] <- stock$F_full[y]/RPmat[,3][y]
    omval$SSBRATIOT[y] <- stock$SSB[y]/RPmat[,4][y]
    if(y == nyear){
      omval$YEAR <- yrs
    }
    
    if(mproc[m, 'ASSESSCLASS']=='WHAM'){
      omval$FRATIO[y] <- stock$res$F.report[length(stock$res$F.report)]/RPmat[,1][y]
      omval$Fest[y,1:length(stock$res$SSB)]<-stock$res$F.report
      omval$Catchest[y,1:length(stock$res$SSB)]<-stock$res$catch
      omval$Rest[y,1:length(stock$res$SSB)]<-stock$res$R
      omval$SSBest[y,1:length(stock$res$SSB)]<-stock$res$SSB
    }
    
    # Assessment model diagnostics ... -1 gives 1 NA. Will change when I get
   
    omval$conv_rate<-conv_rate #MDM
    
    if(mproc[m,'ASSESSCLASS'] == 'WHAM' & !is.na(stock$wham_storage$MohnsRho_SSB[[y]])){
      omval$Mohns_Rho_SSB[y] <- stock$wham_storage$MohnsRho_SSB[[y]]
      # omval$Mohns_Rho_N[r,m,y] <- stock$wham_storage$MohnsRho_N[[r]][[y]] # I have a vector of at-age rho values, looks like asap saves single summary value
      omval$Mohns_Rho_F[y] <- stock$wham_storage$MohnsRho_F[[y]]
      omval$Mohns_Rho_R[y] <- stock$wham_storage$MohnsRho_R[[y]]
      omval$Mest[y,1:length(stock$res$SSB)] <- stock$wham_storage$M[[1]][[y]]
      omval$alphaest[y] <- tail(stock$wham_storage$alpha[[1]][[y]],1)
      omval$betaest[y] <- tail(stock$wham_storage$beta[[1]][[y]],1)
    } else {
      omval$Mohns_Rho_SSB[y]<-Mohns_Rho_SSB[y] 
      omval$Mohns_Rho_F[y]<-Mohns_Rho_F[y]#MDM
      omval$Mohns_Rho_R[y]<-Mohns_Rho_R[y]#MDM
    }
  })
  
  return(out)
  
}

