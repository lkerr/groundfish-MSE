


get_advice <- function(stock){

  # prepare data
  tempStock <- get_tmbSetup(stock = stock)
  
  #### Run assessment model ####
  # Run the CAA assessment
  if(mproc[m,'ASSESSCLASS'] == 'CAA'){
  tempStock <- get_caa(stock = tempStock)
  }
  
  # Run the PlanB assessment
  if(mproc[m,'ASSESSCLASS'] == 'PLANB'){
  tempStock <- get_planB(stock = tempStock)
  }

  # Run ASAP assessment
  if(mproc[m,'ASSESSCLASS'] == 'ASAP'){
    tempStock <- get_ASAP(stock = tempStock)
  }
  
  # was the assessment successful?
  tempStock <- within(tempStock, {
    conv_rate[y] <- ifelse((mproc[m,'ASSESSCLASS'] == 'CAA' && 
                      class(opt) != 'try-error') ||
                     (mproc[m,'ASSESSCLASS'] == 'PLANB' && 
                        class(planBest) != 'try-error') ||
                     (mproc[m, 'ASSESSCLASS'] == 'ASAP' &&
                        asapEst == 0), 1, 0)
  })

    # Retrieve the estimated spawner biomass (necessary for advice) &
    # Vary the parpop depending on the type of assessment model
    # (can't have just one because one of the models might not
    # converge.
    if(mproc[m,'ASSESSCLASS'] == 'CAA'){
      tempStock <- within(tempStock, {
        SSBaa <- rep$J1N * get_dwindow(waa, sty, y-1) * get_dwindow(mat, sty, y-1)
        SSBhat <- apply(SSBaa, 1, sum)
        parpop <- list(waa = tail(rep$waa, 1) / caaInScalar, 
                       sel = tail(rep$slxC, 1), 
                       M = tail(rep$M, 1), 
                       mat = mat[y-1,],
                       R = rep$R * caaInScalar,
                       SSBhat = SSBhat * caaInScalar,
                       J1N = rep$J1N * caaInScalar,
                       Rpar = Rpar,
                       Fhat = tail(rep$F_full, 1))
      })
    }
    
    if(mproc[m,'ASSESSCLASS'] == 'PLANB'){
      tempStock <- within(tempStock, {
        parpop <- list(obs_sumCW = tmb_dat$obs_sumCW,
                       mult = planBest$multiplier,
                       waatrue_y = waa[y-1,],
                       Ntrue_y = J1N[y-1,],
                       Mtrue_y = M,
                       slxCtrue_y = slxC[y-1,])
      })
    }
    
    if(mproc[m,'ASSESSCLASS'] == 'ASAP'){
      tempStock <- within(tempStock, {
        parpop <- list(waa = tail(res$WAA.mats$WAA.catch.fleet1, 1),           
                       sel = tail(res$fleet.sel.mats$sel.m.fleet1, 1),                      
                       M = tail(res$M.age, 1), 
                       mat = res$maturity[1,],                               
                       R = res$SR.resids$recruits,
                       SSBhat = res$SSB,
                       J1N = tail(res$N.age,1),                 ### or use J1B reported in biomass 
                       Rpar = Rpar,
                       Fhat = tail(res$F.report, 1))
      })
    }
  
  if(y > fmyearIdx){
      tempStock<-within(tempStock,{
      peels<-y-fmyearIdx
      if(peels>7){peels<-7}
      if (Sys.info()['sysname'] == "Windows"){
        tempwd<-getwd()
        for (p in (y-peels):y){
          idx<-ncaayear-peels
          SSBold<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', p,'.rdat', sep = ''))$SSB[idx]
          SSBnew<-readRDS(paste(tempwd,'/assessment/ASAP/', stockName, '_', r, '_', y,'.rdat', sep = ''))$SSB[idx]
          assign(paste('rho',p,sep=''),(SSBold-SSBnew)/SSBnew)
        }}
      if (Sys.info()['sysname'] == "Linux"){
        for (p in (y-peels):y){
          idx<-ncaayear-peels
          SSBold<-readRDS(paste(rundir,'/', stockName, '_', r, '_', p,'.rdat', sep = ''))$SSB[idx]
          SSBnew<-readRDS(paste(rundir,'/', stockName, '_', r, '_', y,'.rdat', sep = ''))$SSB[idx]
          assign(paste('rho',p,sep=''),(SSBold-SSBnew)/SSBnew)
        }}
      plist <- mget(paste('rho',(y-peels):y,sep=''))
      pcols <- do.call('cbind', plist)
      Mohns_Rho[y] <- rowSums(pcols) / peels
      cat('Rho calculated.')})}
    if(mproc[m,'rhoadjust'] == 'TRUE'){
      tempStock<-within(tempStock,{
          parpop$SSBhat[length(parpop$SSBhat)]<-parpop$SSBhat[length(parpop$SSBhat)]/(Mohns_Rho[y]+1)
        })}
    # Environmental parameters
    parenv <- list(tempY = temp,
                   Tanom = Tanom,
                   yrs = yrs, # management years
                   yrs_temp = yrs_temp, # temperature years
                   y = y-1)
    
    
    #### Get ref points & assign F ####
    
    # If in the first year or a subsequent year on the reference
    # point update schedule or if using planB instead then run the 
    # reference point update.  || used to keep from evaluating
    # mproc[m,'RPInt'] under planB (it will be NA).
    if( y == fmyearIdx ||
        mproc[m,'ASSESSCLASS'] == 'PLANB' ||
        ( y > fmyearIdx & 
          (y-fyear) > 0 & 
          (y-fyear-1) %% mproc[m,'RPInt'] == 0 ) ){
      
      gnF <- get_nextF(parmgt = mproc[m,], parpop = tempStock$parpop,
                       parenv = parenv,
                       RPlast = NULL, evalRP = TRUE,
                       stock = tempStock)
      tempStock$RPmat[y,] <- gnF$RPs
      
    }else{
      # Otherwise use old reference points to calculate stock
      # status
      tempStock <- within(tempStock, {
        gnF <- get_nextF(parmgt = mproc[m,], parpop = parpop,
                         parenv = parenv,
                         RPlast = RPmat[y-1,], evalRP = FALSE,
                         stock = tempStock)
        RPmat[y,] <- RPmat[y-1,]
      })
    }
    # Report overfished status (based on previous year's data)
    tempStock <- within(tempStock, {
      OFdStatus[y-1] <- gnF$OFdStatus
      
      # Report overfishing status AEW
      OFgStatus[y-1] <- gnF$OFgStatus
      
      # Report maximum gradient component for CAA model
      mxGradCAA[y-1] <- ifelse(mproc[m,'ASSESSCLASS'] == 'CAA',
                               yes = rep$maxGrad,
                               no = NA)
      
      # Tabulate advice (plus small constant)
      adviceF <- gnF$F + 1e-5 
      
      # Calculate expected J1N using parameters from last year's assessment
      # model (i.e., this is Dec 31 of the previous year). Recruitment is
      # just recruitment from the previous year. This could be important
      # depending on what the selectivity pattern is, but if age-1s are
      # not very selected it won't matter much.
      if(mproc$ASSESSCLASS[m] != 'PLANB'){ # is this necessary?
        J1Ny <- get_J1Ny(J1Ny0 = tail(parpop$J1N, 1), 
                         Zy0 = parpop$Fhat * parpop$sel + parpop$M, 
                         Ry1 = tail(parpop$R, 1)) # last years R
        # Absolute Catch advice, inherits units of waa
      }
      
      quota <- get_catch(F_full = adviceF, M = natM[y], N = J1N[y,], selC = slxC[y,])
      quota <- quota %*% waa[y,]
      if(mproc$varlimit == TRUE){
        if(((quota-stock$sumCW[y-1])/quota)*100<(-20)){
          quota<- stock$sumCW[y-1]-(stock$sumCW[y-1]*.2)}
        if(((quota-stock$sumCW[y-1])/quota)*100>20){
          quota<- stock$sumCW[y-1]+(stock$sumCW[y-1]*.2)}
          adviceF<-get_F(x = quota,
                Nv = J1N[y,], 
                slxCv = slxC[y,], 
                M = natM[y], 
                waav = waa[y,])
        }
      
      F_fullAdvice[y] <- adviceF
      ACL[y] <- quota
      
    })
  
  return(tempStock)
  
}







