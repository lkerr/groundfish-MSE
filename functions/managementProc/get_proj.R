get_proj <- function(type, parmgt, parpop, Rfun,parenv,
                     F_val, stReportYr, ny=NULL, stockEnv,block, ...){

  if(parmgt$RFUN_NM == 'hindcastMean'){
    if(type == 'FREF'){
      startHCM <- -parmgt$FREF_PAR0
      endHCM <- parmgt$FREF_PAR1
    }else if(type == 'BREF'){
      startHCM <- -parmgt$BREF_PAR0
      endHCM <- parmgt$BREF_PAR1
    }
    else if(type=='current'){#'current' being the current method for New England groundfish which uses projections in the catch advice 
      startFCST <- parenv$y
      endFCST <- parenv$y + 2
    }
    
    # Tanom is unnecessary for hindcasts. Loop below is based on the length
    # of Tanom (relevant to "forecast") so adapt this variable to be the
    # appropriate length.
    Tanom <- rep(0, length(startFCST:endFCST))
    
    # length of recruitment time series
    nR <- length(parpop$R)

    # historical R estimates over the time window specified in the file mprocfile (defined in set_om_parameters_global.R)
    Rest <- get_dwindow(parpop$R, 
                        start = unlist(nR- (-startHCM) + 1), 
                        end = unlist(nR - (-endHCM) + 1))
    
  }
   
  if(parmgt$RFUN_NM == 'forecast'){

    if(type == 'FREF'){
      startFCST <- parenv$y
      endFCST <- parenv$y + parmgt$FREF_PAR0
    }else if(type == 'BREF'){
      startFCST <- parenv$y
      endFCST <- parenv$y + parmgt$BREF_PAR0
    }
    else if(type=='current'){
      startFCST <- parenv$y
      endFCST <- parenv$y + 2
    }
  }
  
  # Get the initial population for the simulation -- assumes exponential 
  # survival based on the given F, mean recruitment and M
  # ages <- 1:length(parpop$sel)
  # meanR <- mean(parpop$R)
  # init <- meanR * exp(-ages * F_val*parpop$sel - as.numeric(parpop$M))

  # The initial population is the estimates in the last year
  init <- tail(parpop$J1N,1)

  if(type=='current'){
    suminit<-sum(init)
    suminit<-get_error_idx(type=stockEnv$oe_sumIN_typ, idx=suminit, par=stockEnv$pe_IA)
    initpaa<-get_error_paa(paa=init, par=10000)
    init<-suminit*initpaa
  }

  # Ensure that all vectors are the same length
  if(!all(length(parpop$sel) == length(init),
          length(parpop$sel) == length(parpop$waa))){
    stop('get_proj: check vector lengths')
  }

  # If M is a vector, ensure it is the same length as the rest

  if(length(parpop$M) > 1){
    if(length(parpop$sel) != length(parpop$M)){
      stop('get_proj: check vector lengths (M)')
    }
  }
  
  nage <- length(parpop$sel)

  # if M is not given as a vector, make it one

  if(length(parpop$M) == 1){
    if(parpop$switch==TRUE){
    parpop$M <- rep(tail(na.omit(stockEnv$natM),1), nage)}
    else if(parpop$switch==FALSE){
      parpop$M <- rep(0.2, nage)
    }
    else{parpop$M<-rep(parpop$M,nage)}
    
  }

  # set up containers
  N <- matrix(0, nrow=length(startFCST:endFCST), ncol=nage)

  # set up initial conditions
  N[1,] <- init 
  #Get beginning of year population in year t+1
  if (type=='current'){
    Fhat<-parpop$Fhat
    for(a in 2:(nage-1)){
      #init= population at the beginning of the year in t-1  
      #exponential survival to the next year/age (t)
      N[1,a] <- init[a-1] * exp(-parpop$sel[a-1]*Fhat - 
                                    parpop$M[a-1])
    }
    
    # Deal with the plus group
    N[1,nage] <- init[nage-1] * exp(-parpop$sel[nage-1] * Fhat - 
                                       parpop$M[nage-1]) + 
      init[nage] * exp(-parpop$sel[nage] * Fhat - 
                          parpop$M[nage])
    
    Recruits<-parpop$R
    
    N[1,1] <- prod(tail(Recruits,5))^(1/5)

    if (mproc$rhoadjust==TRUE & y>fmyearIdx & stockEnv$Mohns_Rho_SSB[y]>0.15){
      N[1,]<-N[1,]/(1+stockEnv$Mohns_Rho_SSB[y])
    }
  }

  for(y in 2:length(startFCST:endFCST)){
  Fvalue<-F_val
  if (type=='current'){
    if (y==2 & !exists('catchproj',stockEnv)){
      Fvalue<-parpop$Fhat
    }
    if (y==2 & exists('catchproj',stockEnv)){
      Fvalue<-get_F(x = stockEnv$catchproj[2],
                    Nv = init, 
                    slxCv = parpop$sel, 
                    M = parpop$M, 
                    waav = parpop$waa)
    }
  }
    for(a in 2:(nage-1)){
      #N[y-1] is the population at the beginning of the previous year 
      #exponential survival to the next year/age
      N[y,a] <- N[y-1, a-1] * exp(-parpop$sel[a-1]*Fvalue - 
                                    parpop$M[a-1])
    }

    # Deal with the plus group
      N[y,nage] <- N[y-1,nage-1] * exp(-parpop$sel[nage-1] * Fvalue - 
                                       parpop$M[nage-1]) + 
                 N[y-1,nage] * exp(-parpop$sel[nage] * Fvalue - 
                                     parpop$M[nage])
    
    ## Recruitment
    # sd of historical R estimates
      parpop$Rpar_mis<-stockEnv$Rpar_mis#will use incorrect recruitment assumption if set in model parameters script
      if(type=='current'){parpop$switch<-'TRUE'}
      SSB<-c(N[y-1,]) %*% c(parpop$waa* parpop$mat)

        N[y,1] <- Rfun(type = stockEnv$R_typ,
                     parpop = parpop, 
                     parenv = parenv, 
                     parmgt = parmgt,
                     SSB = SSB,
                     sdR = 0,
                     TAnom = 0,
                     y=y,
                     block=block)
}
      #if(type=='BREF'){N[y,1]<-7165447}

  Waa <- sweep(N, MARGIN=2, STATS=parpop$waa, FUN='*')
  
  # Get mature biomass-at-age
  SSBaa <- sweep(Waa, MARGIN=2, STATS=parpop$mat, FUN='*')

  # Calculate the catch in weight

  sumCW <- sapply(2:nrow(N), function(i){
    CN <- (parpop$sel * F_val) / (parpop$sel * F_val + parpop$M) * 
      N[i,] * (1 - exp(-F_val * parpop$sel - parpop$M))
    tempSumCW <- CN %*% c(parpop$waa)
    return(tempSumCW)
  })
  
  J1Npj <- N

  SSBaa <- SSBaa
  SSBpj <- apply(SSBaa, 1, sum)
  sumCWpj <- sumCW
  out <- list(J1N = J1Npj,
              SSBaa = SSBaa,
              SSB = SSBpj,
              sumCW = sumCWpj)
  
  return(out)
  
}


