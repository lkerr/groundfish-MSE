

# Function to initialize the stocks

get_popInit <- function(stock){

  stock <- within(stock, {

    # First few years of fishery information
    # F_full[1:(ncaayear + fyear + nburn +1)] <- rlnorm(ncaayear + 
    #                                                   fyear + nburn + 1, 
    #                                                   log(0.2), 0.1)
    F_full[1:(fyear-1)] <- rlnorm(fyear-1, log(0.2), burnFsd)
    
    #### Initilizations ####
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
    
    
    # calculate length-at-age
    laaTemp <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                               ages=fage:page, Tanom=0)
    laa[1:(fyear-1),] <- rep(laaTemp, each = (fyear-1))
    # other option here is get_size which tries to take temperature
    # into account. Needs some work there though.
    
    # calculate weight-at-age in year y
    waaTemp <- get_weightAtAge(type=waa_typ, par=waa_par, 
                               laa=laaTemp, inputUnit='kg')
    waa[1:(fyear-1),] <- rep(waaTemp, each = (fyear-1))
    
    # calculate maturity in year y
    matTemp <- get_maturity(type=mat_typ, par=mat_par, laa=laaTemp)
    mat[1:(fyear-1),] <- rep(matTemp, each = (fyear-1))
    
    slxTemp <- get_slx(type=selC_typ, par=selC, laa=laaTemp)
    slxC[1:(fyear-1),] <- rep(matTemp, each = (fyear-1))
    
    # calculate recruits in year y based on the SSB in years previous
    # (depending on the lag) and temperature (forget time lag here)
    SSB[1:(fyear-1)] <- sum(J1N[1:(fyear-1),] * 
                            mat[1:(fyear-1),] * waa[1:(fyear-1),])
    
  })

    # Determine the F for the rest of the burn-in period based on the
    # calculation of Fmsy and the proportion given in the parameter file.
  out <- within(stock, {  
    burnFmsy <- get_burnF(stock)
    burnFmean <- burnFmsyScalar * burnFmsy
    F_full[((fyear-1)+1):fmyearIdx] <- rlnorm(fmyearIdx - ((fyear-1)+1)+1, 
                                              log(burnFmean), burnFsd)
  })
  
  return(out)
  
}





