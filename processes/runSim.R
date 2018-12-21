
set.seed(88)

# empty the environment
rm(list=ls())
# set.seed(2) 

source('processes/runSetup.R')

# if on local machine (i.e., not hpcc) must compile the tmb code
# (HPCC runs have a separate call to compile this code). Keep out of
# runSetup.R because it is really a separate process on the HPCC.
if(runClass != 'HPCC'){
  source('processes/runPre.R', local=ifelse(exists('plotFlag'), TRUE, FALSE))
}

# begin the model loop
for(r in 1:nrep){

  if(debugSink & runClass != 'HPCC'){
    cat('r = ', r, '\n', file=dbf, append=TRUE)
  }
  
  # Use the same random numbers for each of the management strategies
  # set.seed(NULL)
  # rsd <- rnorm()
  
  for(m in 1:nrow(mproc)){
    
    if(debugSink & runClass != 'HPCC'){
      cat('  r =', r, 'm =', m, '\n', file=dbf, append=TRUE)
    }
    
    # set.seed(rsd)
    
    # First few years of fishery information
    # F_full[1:(ncaayear + fyear + nburn +1)] <- rlnorm(ncaayear + 
    #                                                   fyear + nburn + 1, 
    #                                                   log(0.2), 0.1)
    F_full[1:fmyearIdx] <- rlnorm(fmyearIdx, log(burnFmean), burnFsd)
  
    # initialize the model with numbers and mortality rates
    # in the first n (fyear-1) years.
    
    
    initN <- get_init(nage=nage, N0=2e7, F_full=F_full[1], M=M)
    J1N[1:(fyear-1),] <- rep(initN, each=(fyear-1))
    laa[1:(fyear-1),] <- rep(get_lengthAtAge(type='vonB', par=laa_par, 
                                         ages=fage:page, Tanom=0),
                             each=(fyear-1))
    waa[1:(fyear-1),] <- get_weightAtAge(type='aLb', par=waa_par, 
                                         laa=laa[1:(fyear-1),],
                                         inputUnit='kg')
    Z[1:(fyear-1),] <- rep(F_full[1]+M, each=(fyear-1))
  
    RPs_rm <- matrix(NA, nrow=nyear, ncol=2,
                     dimnames=list(paste0('y', 1:nyear),
                                   c('FREF', 'BREF')))
    
    for(y in fyear:nyear){

      if(debugSink & runClass != 'HPCC'){
        cat('    r =', r, 'm =', m, 'y =', y, '\n', file=dbf, append=TRUE)
      }
      
      # calculate length-at-age in year y
      laa[y,] <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                                 ages=fage:page, Tanom=Tanom[y])
      # other option here is get_size which tries to take temperature
      # into account. Needs some work there though.
      
      # calculate weight-at-age in year y
      waa[y,] <- get_weightAtAge(type=waa_typ, par=waa_par, 
                                 laa=laa[y,], inputUnit='kg')
      
      # calculate maturity in year y
      mat[y,] <- get_maturity(type=mat_typ, par=mat_par, laa=laa[y,])
      
      # calculate recruits in year y based on the SSB in years previous
      # (depending on the lag) and temperature
      SSB[y] <- sum(J1N[y-fage,] * mat[y,] * waa[y-fage,])  

      Rout <- get_recruits(type='BHTS', par=Rpar, S=SSB[y],
                           TAnom=Tanom[y], R_ym1 = R[y-1], Rhat_ym1 = Rhat[y-1])

      R[y] <- Rout[['R']]
      Rhat[y] <- Rout[['Rhat']]
      R[y] <- ifelse(R[y] < 0, 0, R[y])
      
      # calculate the selectivity in year y (changes if the laa changes)
      slxC[y,] <- get_slx(type=selC_typ, par=selC, laa=laa[y,])
      slxI[y,] <- get_slx(type=selI_typ, par=selI, laa=NULL)
      
      # get Z for the current year
      Z[y,] <- F_full[y]*slxC[y,] + M
      
      # calculate what the Jan 1 population numbers are for year y, which
      # depend on the numbers and mortality rate in the previous year and
      # on the recruitment this year
      J1N[y,] <- get_J1Ny(J1Ny0=J1N[y-1,], Zy0=Z[y-1,], R[y])
    
      # calculate the predicted catch in year y, the catch weight and the
      # proportions of catch numbers-at-age. Add small number in case F=0
      CN[y,] <- get_catch(F_full=F_full[y], M=M, 
                          N=J1N[y,], selC=slxC[y,]) + 1e-3
      sumCW[y] <- CN[y,] %*% waa[y,]    # (dot product)
      paaCN[y,] <- (CN[y,]) / sum(CN[y,])
 
      # calculate the predicted survey index in year y and the predicted
      # survey proportions-at-age
      IN[y,] <- get_survey(F_full=F_full[y], M=M, N=J1N[y,], slxC[y,], 
                           slxI=1, timeI=timeI, qI=qI)
      sumIN[y] <- sum(IN[y,])
      paaIN[y,] <- IN[y,] / sum(IN[y,])
      
      # calculate effort based on catchability and the implemented fishing
      # mortality. Effort not typically derived ... could go the other way
      # around and implement E as a policy and calculate F.
      effort[y] <- F_full[y] / qC
      obs_effort[y] <- get_error_idx(type=oe_effort_typ, idx=effort[y], 
                                     par=oe_effort)
      
      # Get observation error data for the assessment model
      obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ, 
                                    idx=sumCW[y] * ob_sumCW, 
                                    par=oe_sumCW)
      obs_paaCN[y,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y,], 
                                     par=oe_paaCN)
      obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, 
                                    idx=sumIN[y] * ob_sumIN, 
                                    par=oe_sumIN)
      obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], 
                                     par=oe_paaIN)

      # if burn-in period is over...
      if(y > fmyearIdx-1){
         
        # prepare data & run assessment model
        source('processes/get_tmb_setup.R')

        # include sink file just to keep the console output clean
        if(debugSink & runClass != 'HPCC'){
          cat('      trying assessment...', file=dbf, append=TRUE)
        }
        
        # Run the CAA assessment
        tryfitCAA <- try(source('assessment/caa.R'))
        # Run the PlanB assessment
        tryfitPlanB <- try(source('assessment/planB.R'))
     
        # was the assessment successful?
        conv <- ifelse((mproc[m,'ASSESSCLASS'] == 'CAA' & 
                        class(tryfitCAA) != 'try-error') ||
                       (mproc[m,'ASSESSCLASS'] == 'PLANB' & 
                        class(tryfitPlanB) != 'try-error'),
                       yes = 1, no = 0)
       
        if(debugSink & runClass != 'HPCC'){
          cat('/...assessment complete\n', file=dbf, append=TRUE)
        }

        if(conv){
          
          # Retrieve the estimated spawner biomass (necessary for advice)
          SSBaa <- rep$J1N * get_dwindow(waa, sty, y) * get_dwindow(mat, sty, y)
          SSBhat <- apply(SSBaa, 1, sum)
          
          # Get fishing mortality for next year's management
          # fbrpy <- get_FBRP(type=fbrpTyp, par=mproc[m,],
                            # sel=endv(rep$slxC), waa=endv(rep$waa), 
                            # M=M[1])
          # note must convert matrices to vectors when using tail() function
          # to get the appropriate behavior
          # bbrpy <- get_BBRP(type=bbrpTyp, par=mproc[m,],
                            # sel=endv(rep$slxC), waa=endv(rep$waa), 
                            # M=endv(rep$M), mat=mat[y,], 
                            # R=rep$R, B=SSBhat, Rfun=mean)
          
          # apply the harvest control rule
          
          # Vary the parpop depending on the type of assessment model
          # (can't have just one because one of the models might not
          # converge.
          if(mproc[m,'ASSESSCLASS'] == 'CAA'){
            parpop <- list(waa = tail(rep$waa, 1), 
                           sel = tail(rep$slxC, 1), 
                           M = tail(rep$M, 1), 
                           mat = mat[y,],
                           R = rep$R,
                           SSBhat = SSBhat,
                           J1N = rep$J1N,
                           Rpar = Rpar,
                           Fhat = tail(rep$F_full, 1))
            
          }else if(mproc[m,'ASSESSCLASS'] == 'PLANB'){
            parpop <- list(obs_sumCW = tmb_dat$obs_sumCW,
                           mult = tryfitPlanB$value$multiplier,
                           waatrue_y = waa[y,],
                           Ntrue_y = J1N[y,],
                           Mtrue_y = M,
                           slxCtrue_y = slxC[y,])
          }
          
          # Environmental parameters
          parenv <- list(tempY = temp,
                         Tanom = Tanom,
                         y = y)
          
          # If in the first year or a subsequent year on the reference
          # point update schedule or if using planB instead then run the 
          # reference point update.  || used to keep from evaluating
          # mproc[m,'RPInt'] under planB (it will be NA).
          if( y == fmyearIdx ||
              mproc[m,'ASSESSCLASS'] == 'PLANB' ||
              ( y > fmyearIdx & 
                (y-fyear) > 0 & 
                (y-fyear-1) %% mproc[m,'RPInt'] == 0 ) ){
            
            gnF <- get_nextF(parmgt = mproc[m,], parpop = parpop,
                             parenv = parenv,
                             RPlast = NULL, evalRP=TRUE)
            RPmat[y,] <- gnF$RPs
            
          }else{
            # Otherwise use old reference points to calculate stock
            # status
            gnF <- get_nextF(parmgt = mproc[m,], parpop = parpop,
                             parenv = parenv,
                             RPlast = RPmat[y-1,], evalRP = FALSE)
            RPmat[y,] <- RPmat[y-1,]
          }
          # Report overfished status
          OFdStatus[y] <- gnF$OFdStatus
          
          # Report maximum gradient component for CAA model
          mxGradCAA[y] <- ifelse(mproc[m,'ASSESSCLASS'] == 'CAA',
                                 yes = rep$maxGrad,
                                 no = NA)
         
          # Tabulate advice (plus small constant)
          nextF <- gnF$F + 1e-5

         
          
          if(y < nyear){
            F_full[y+1] <- nextF
          }
          

        }else{
          
          # if the assessment model didn't work then fill the
          # array with NAs
          for(i in 2:length(oacomp)){
            # Determine the dimensionality of each oacomp list component
            # and create a character object with the appropriate
            # number of commas and then evaluate to fill arrays
            # with NAs
            d <- dim(oacomp[[i]])
            commas <- paste0(rep(',', length(d)-1), collapse='')
            eval(parse(text=paste0('oacomp[[i]][', commas, '] <- NA')))
          }
          
          # After filling the arrays with NA values, break out of
          # the loop and move on to the next management strategy
          break
          
        }
          
        # Get fishing mortality for next year's management
        # fbrpy <- get_FBRP(type=fbrpTyp, par=mgtproc[m,],
                          # sel=endv(rep$slxC), waa=endv(rep$waa), 
                          # M=M[1])
        # note must convert matrices to vectors when using tail() function
        # to get the appropriate behavior
        # bbrpy <- get_BBRP(type=bbrpTyp, par=mgtproc[m,],
                          # sel=endv(rep$slxC), waa=endv(rep$waa), 
                          # M=endv(rep$M), mat=mat[y,], 
                          # R=rep$R, B=SSBhat, Rfun=mean)
  
        # # apply the harvest control rule
        # parpop <- list(waa = tail(rep$waa, 1), 
        #                sel = tail(rep$slxC, 1), 
        #                M = tail(rep$M, 1), 
        #                mat = mat[y,],
        #                R = rep$R,
        #                B = SSBhat)
        # 
        # # recommended level of fishing mortality for the next year
        # nextF_rec <- get_nextF(parmgt = mproc[m,], parpop = parpop)
        # nextF <- get_ieF(type='lognormal', F, par=ie_F)
        # 
        # if(y < nyear){
        #   F_full[y+1] <- nextF
        # }
  
      }
      
      if(mproc[m,'ASSESSCLASS'] == 'CAA' & y > fmyearIdx-1){
        relE_qI[y] = get_relE(rep$log_qI, log(qI))
        relE_qC[y] = get_relE(rep$log_qC, log(qC))
        # Use max selectivity ... a little weird but they do go together
        relE_selCs0[y] = get_relE(rep$log_selC[1], log(selC['s0']))
        relE_selCs1[y] = get_relE(rep$log_selC[2], log(selC['s1']))
        relE_ipop_mean[y] = get_relE(rep$log_ipop_mean, log_ipop_mean)
        relE_ipop_dev[y] = mean(get_relE(rep$ipop_dev, ipop_dev))
        relE_R_dev[y] = mean(get_relE(rep$R_dev, R_dev))
      }
     
      
    }
    # Fill the arrays with results
    source('processes/fill_repArrays.R')
  }
}


# Output run time / date information and OM inputs. The random number is
# just ensuring that no simulations will be overwritten because the hpcc
# might finish some in the same second. td is used for uniquely naming the
# output file as well as for listing in the output results.
td <- as.character(Sys.time())
td2 <- gsub(':', '', td)
td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')



# save results
save(omval, file=paste0('results/sim/omval', td2, '.Rdata'))

if(runClass != 'HPCC'){
  ompar <- readLines('processes/set_om_parameters.R')
  cat('\n\nFin.\n\n',
      'Completion at: ',
      td,
      file='results/runInfo.txt', sep='')
  cat('\n\n\n\n\n\n\n\n  ##### OM Parameters ##### \n\n',
      ompar,
      file='results/runInfo.txt', sep='\n', append=TRUE)
}



if(platform == 'Windows'){
  source('processes/runPost.R')
}


print(unique(warnings()))

print(paste('r =', r, 'm = ', m, 'y =', y))
print(' ---- Fin ----')
