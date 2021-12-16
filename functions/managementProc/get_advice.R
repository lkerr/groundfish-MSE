


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
    conv <- ifelse((mproc[m,'ASSESSCLASS'] == 'CAA' && 
                   class(opt) != 'try-error') ||
                   (mproc[m,'ASSESSCLASS'] == 'PLANB' && 
                   class(planBest) != 'try-error') ||
                   (mproc[m, 'ASSESSCLASS'] == 'ASAP' &&
                   class(asapEst) != 'try-error'),
                   yes = 1, no = 0)
  })
  
  if(tempStock$conv){
    # When using an analytical assessmsent, retrieve the estimated spawner biomass (necessary for advice)
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
      
      F_fullAdvice[y] <- adviceF
      ACL[y] <- quota
      
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







