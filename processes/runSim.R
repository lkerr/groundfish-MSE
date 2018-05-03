



# empty the environment
rm(list=ls())


# prepare directories
prepFiles()


# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE)
sapply(ffiles, source)


# load the required libraries
source('processes/loadLibs.R')


# get the operating model parameters
source('processes/set_om_parameters.R')


# get all the necessary containers for the simulation
source('processes/get_containers.R')


# begin the model loop
for(r in 1:nrep){


  # initialize the model with numbers and mortality rates
  # in the first n (fyear-1) years.
  
  initN <- get_init(nage=nage, N0=2e7, F_full=F_full[1], M=M)
  J1N[1:(fyear-1),] <- rep(initN, each=(fyear-1))
  laa[1:(fyear-1),] <- rep(get_lengthAtAge(type='vonB', par=laa_par, 
                                       ages=fage:page),
                           each=(fyear-1))
  waa[1:(fyear-1),] <- get_weightAtAge(type='aLb', par=waa_par, 
                                       laa=laa[1:(fyear-1),],
                                       inputUnit='kg')
  Z[1:(fyear-1),] <- rep(F_full[1]+M, each=(fyear-1))



  for(y in fyear:nyear){
  
    # calculate length-at-age in year y
    laa[y,] <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                               ages=fage:page)
    # other option here is get_size which tries to take temperature
    # into account. Needs some work there though.
    
    # calculate weight-at-age in year y
    waa[y,] <- get_weightAtAge(type=waa_typ, par=waa_par, 
                               laa=laa[y,], inputUnit='kg')
    
    # calculate maturity in year y
    mat <- get_maturity(type=mat_typ, par=mat_par, laa=laa[y,])
    
    # calculate recruits in year y based on the SSB in years previous
    # (depending on the lag) and temperature
    SSB[y] <- sum(J1N[y-fage,] * mat * waa[y-fage,])  

    Rpar <- get_recruitment_par(par=srpar, stochastic=FALSE)
    Rout <- get_recruits(type=Rpar$type, par=Rpar, S=SSB[y],
                         tempY=temp[y], resid0 = residR[y-1])
    R[y] <- Rout['R']
    residR[y] <- Rout['resid']
    R[y] <- ifelse(R[y] < 0, 0, R[y])
    
    # calculate the selectivity in year y (changes if the laa changes)
    slxC[y,] <- get_slx(type=selC_typ, par=selC, laa=laa[y,])
    
    # get Z for the current year
    Z[y,] <- F_full[y]*slxC[y,] + M
    
    # calculate what the Jan 1 population numbers are for year y, which
    # depend on the numbers and mortality rate in the previous year and
    # on the recruitment this year
    J1N[y,] <- get_J1Ny(J1Ny0=J1N[y-1,], Zy0=Z[y-1,], R[y])
    
    # calculate the predicted catch in year y, the catch weight and the
    # proportions of catch numbers-at-age
    CN[y,] <- get_catch(F_full=F_full[y], M=M, N=J1N[y,], selC=slxC[y,])
    sumCW[y] <- CN[y,] %*% waa[y,]    # (dot product)
    paaCN[y,] <- CN[y,] / sum(CN[y,])
  
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
    obs_sumCW[y] <- get_error_idx(type=oe_sumCW_typ, idx=sumCW[y], par=oe_sumCW)
    obs_paaCN[y,] <- get_error_paa(type=oe_paaCN_typ, paa=paaCN[y,], par=oe_paaCN)
    obs_sumIN[y] <- get_error_idx(type=oe_sumIN_typ, idx=sumIN[y], par=oe_sumIN)
    obs_paaIN[y,] <- get_error_paa(type=oe_paaIN_typ, paa=paaIN[y,], par=oe_paaIN)
  
  
    # prepare data for assessment model (if burn-in period is over)
    if(y > ncaayear + fyear + nburn){
  
      source('processes/get_tmb_setup.R')
      source('assessment/caa.R')
      y2 <- y - (ncaayear + fyear + nburn)
      source('processes/fill_repArrays.R')

    }
    
    
  }
}


