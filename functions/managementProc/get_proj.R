get_proj <- function(type, parmgt, parpop, parenv, Rfun,
                     F_val, stReportYr, ny=NULL, stockEnv, ...){

  if(parmgt$RFUN_NM == 'hindcastMean'){
    if(type == 'FREF'){
      startHCM <- parmgt$FREF_PAR0
      endHCM <- parmgt$FREF_PAR1
    }else if(type == 'BREF'){
      startHCM <- parmgt$BREF_PAR0
      endHCM <- parmgt$BREF_PAR1
    }
    else if(type=='current'){
      startFCST <- parenv$y
      endFCST <- parenv$y + 2
    }
    
    # Tanom is unnecessary for hindcasts. Loop below is based on the length
    # of Tanom (relevant to "forecast") so adapt this variable to be the
    # appropriate length.
    Tanom <- rep(0, ny)
    
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
    
    if(is.na(parenv$Tanom[endFCST])){
      stop(paste('get_proj: end projection year out of temperature anomaly',
                 'range. Check FREF_PAR0 or BREF_PAR0 in mproc.'))
    }
    
    Tanom <- parenv$Tanom[startFCST:endFCST]
       
    ny <- length(Tanom)
    
  }
  
 
  # Get the initial population for the simulation -- assumes exponential 
  # survival based on the given F, mean recruitment and M
  # ages <- 1:length(parpop$sel)
  # meanR <- mean(parpop$R)
  # init <- meanR * exp(-ages * F_val*parpop$sel - as.numeric(parpop$M))
   
  # The initial population is the estimates in the last year
  init <- tail(parpop$J1N, 1)

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
    parpop$M <- rep(parpop$M, nage)
  }
  
  # set up containers
  N <- matrix(0, nrow=ny, ncol=nage)

  # set up initial conditions
  N[1,] <- init
  for(y in 2:length(Tanom)){
    for(a in 2:(nage-1)){
      # exponential survival to the next year/age
      N[y,a] <- N[y-1, a-1] * exp(-parpop$sel[a-1]*F_val - 
                                    parpop$M[a-1])
    }
   
    # Deal with the plus group
    N[y,nage] <- N[y-1,nage-1] * exp(-parpop$sel[nage-1] * F_val - 
                                       parpop$M[nage-1]) + 
                 N[y-1,nage] * exp(-parpop$sel[nage] * F_val - 
                                     parpop$M[nage])
    
    ## Recruitment
    # sd of historical R estimates

    N[y,1] <- Rfun(type = stockEnv$R_typ,
                   parpop = parpop, 
                   parenv = parenv, 
                   SSB = c(N[y-1,]) %*% c(parpop$waa* parpop$mat),
                   sdR = stockEnv$pe_R,
                   TAnom = Tanom[y],
                   Rest = Rest)

  }

  # Get weight-at-age
  Waa <- sweep(N, MARGIN=2, STATS=parpop$waa, FUN='*')
  
  # Get mature biomass-at-age
  SSBaa <- sweep(Waa, MARGIN=2, STATS=parpop$mat, FUN='*')

  # Calculate the catch in weight
  sumCW <- sapply(2:nrow(N), function(i){
    CN <- get_catch(F_full=F_val, M=parpop$M,
                    N=N[(i-1),], selC=parpop$sel) + 1e-3
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


