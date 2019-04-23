

# Function to initialize the stocks

get_popInit <- function(stock){

  out <- within(stock, {

    # First few years of fishery information
    # F_full[1:(ncaayear + fyear + nburn +1)] <- rlnorm(ncaayear + 
    #                                                   fyear + nburn + 1, 
    #                                                   log(0.2), 0.1)
    F_full[1:fmyearIdx] <- rlnorm(fmyearIdx, log(burnFmean), burnFsd)
    
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
    
    RPs_rm <- matrix(NA, nrow=nyear, ncol=2,
                     dimnames=list(paste0('y', 1:nyear),
                                   c('FREF', 'BREF')))
    
  })
  
  return(out)
  
}





