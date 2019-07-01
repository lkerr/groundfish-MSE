


get_advice <- function(stock){

  # prepare data
  tempStock <- get_tmbSetup(stock = stock)
  
  #### Run assessment model ####
  # Run the CAA assessment
  tempStock <- get_caa(stock = tempStock)
  
  # Run the PlanB assessment
  tempStock <- get_planB(stock = tempStock)
  

  # was the assessment successful?
  tempStock <- within(tempStock, {
    conv <- ifelse((mproc[m,'ASSESSCLASS'] == 'CAA' & 
                   class(opt) != 'try-error') ||
                   (mproc[m,'ASSESSCLASS'] == 'PLANB' & 
                   class(planBest) != 'try-error'),
                   yes = 1, no = 0)
  })
  
  if(tempStock$conv){
    
    # Retrieve the estimated spawner biomass (necessary for advice)
    tempStock <- within(tempStock, {
      SSBaa <- rep$J1N * get_dwindow(waa, sty, y) * get_dwindow(mat, sty, y)
      SSBhat <- apply(SSBaa, 1, sum)
    })
    
    
    # Vary the parpop depending on the type of assessment model
    # (can't have just one because one of the models might not
    # converge.
    if(mproc[m,'ASSESSCLASS'] == 'CAA'){
      tempStock <- within(tempStock, {
      parpop <- list(waa = tail(rep$waa, 1) / caaInScalar, 
                     sel = tail(rep$slxC, 1), 
                     M = tail(rep$M, 1), 
                     mat = mat[y,],
                     R = rep$R * caaInScalar,
                     SSBhat = SSBhat * caaInScalar,
                     J1N = rep$J1N * caaInScalar,
                     Rpar = Rpar,
                     Fhat = tail(rep$F_full, 1))
      })
      
    }else if(mproc[m,'ASSESSCLASS'] == 'PLANB'){
      tempStock <- within(tempStock, {
        parpop <- list(obs_sumCW = tmb_dat$obs_sumCW,
                       mult = planBest$multiplier,
                       waatrue_y = waa[y,],
                       Ntrue_y = J1N[y,],
                       Mtrue_y = M,
                       slxCtrue_y = slxC[y,])
        })
    }
    
    # Environmental parameters
    parenv <- list(tempY = temp,
                   Tanom = Tanom,
                   yrs = yrs, # management years
                   yrs_temp = yrs_temp, # temperature years
                   y = y)

    
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
    # Report overfished status
    tempStock <- within(tempStock, {
      OFdStatus[y] <- gnF$OFdStatus
      
      # Report maximum gradient component for CAA model
      mxGradCAA[y] <- ifelse(mproc[m,'ASSESSCLASS'] == 'CAA',
                             yes = rep$maxGrad,
                             no = NA)
      
      # Tabulate advice (plus small constant)
      adviceF <- gnF$F + 1e-5 
    
      # Absolute Catch advice
      quota <- get_catch(F_full=adviceF, M=M, N=J1N[y,], selC=slxC[y,])
      quota<-quota%*%waa[y,]
      
  
      if(y < nyear){
        F_fullAdvice[y+1] <- adviceF
        ACL[y+1] <- quota
      }
    })
      
  }else{
    
    # if the assessment model didn't work then fill the
    # array with NAs
    tempStock <- within(tempStock, {
      for(i in 2:length(oacomp)){
        # Determine the dimensionality of each oacomp list component
        # and create a character object with the appropriate
        # number of commas and then evaluate to fill arrays
        # with NAs
        d <- dim(oacomp[[i]])
        commas <- paste0(rep(',', length(d)-1), collapse='')
        eval(parse(text=paste0('oacomp[[i]][', commas, '] <- NA')))
      }
    })
  
    # After filling the arrays with NA values, break out of
    # the loop and move on to the next management strategy
    break
  }

  return(tempStock)
  
}







