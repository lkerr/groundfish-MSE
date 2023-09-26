#' @description Initialize the stocks
#' 
#' @param stock A storage object for a single species
#' 
#' @return A revised storage object (out) with updated:
#' \itemize{
#'  \item{}
#'  \item{}
#' }

get_popInit <- function(stock){

  stock <- within(stock, {

    # First few years of fishery information
    # F_full[1:(ncaayear + fyear + nburn +1)] <- rlnorm(ncaayear + 
    #                                                   fyear + nburn + 1, 
    #                                                   log(0.2), 0.1)
    F_full[1:fyear] <- rlnorm(fyear, log(0.2), burnFsd)

    #### Initilizations ####
    # initialize the model with numbers and mortality rates

    # in the first n (fyear-1) years.
   
    initN <- get_init(type = initN_type, par = initN_par)

    
    J1N[1:fyear,] <- rep(initN, each=fyear)
    
    natM[1:fyear] <- rep(init_M, each = fyear) #AEW
    
    laa[1:(fyear-1),] <- rep(get_lengthAtAge(type='vonB', par=laa_par, 
                                             ages=fage:page, Tanom=0),
                             each=(fyear-1))
    slxC[1:(fyear-1),] <- get_slx(type = selC_typ, par = selC, 
                                  laa = laa[1:(fyear-1),])
    CN[1:(fyear-1),] <- get_catch(F_full = F_full[1:(fyear-1)], M = init_M,
                                  N = J1N[1:(fyear-1),],
                                  selC = slxC[1:(fyear-1),])
    waa[1:(fyear-1),] <- get_weightAtAge(type=waa_typ, par=waa_par, 
                                         laa=laa[1:(fyear-1),],
                                         inputUnit='kg',y=1,fmyearIdx=fmyearIdx)
    
    paaCN[1:(fyear-1),] <- (CN[1:(fyear-1),]) / sum(CN[1:(fyear-1),])
    survey <- get_survey(F_full=F_full[1:(fyear-1)], M=init_M, 
                                   N=J1N[1:(fyear-1),], slxC[1:(fyear-1),], 
                                   slxI=selI, timeI=timeI, qI=qI,q_settings=FALSE,Tanom=0,y=1)
    IN[1:(fyear-1),] <- unlist(survey$I)
    
    sumIN[1:(fyear-1)] <- sum(IN[1:(fyear-1),])
    sumIW[1:(fyear-1)] <- apply(IN[1:(fyear-1),] * waa[1:(fyear-1),], 1, sum)
    paaIN[1:(fyear-1),] <- IN[1:(fyear-1),] / sum(IN[1:(fyear-1),])
    
    effort[1:(fyear-1)] <- F_full[1:(fyear-1)] / qC
    
    
    Z[1:(fyear-1),] <- rep(F_full[1]+init_M, each=(fyear-1))
    
    
    # calculate length-at-age
    laaTemp <- get_lengthAtAge(type=laa_typ, par=laa_par, 
                               ages=fage:page, Tanom=0)
    laa[1:fyear,] <- rep(laaTemp, each = fyear)
    # other option here is get_size which tries to take temperature
    # into account. Needs some work there though.
    
    # calculate weight-at-age in year y
    waaTemp <- get_weightAtAge(type=waa_typ, par=waa_par, 
                               laa=laaTemp, inputUnit='kg',y=1,fmyearIdx=fmyearIdx) 

    waa[1:fyear,] <- rep(waaTemp, each = fyear)
    
    # calculate maturity in year y
    matTemp <- get_maturity(type=mat_typ, par=mat_par, laa=laaTemp,y=1,fmyearIdx=fmyearIdx)
    mat[1:fyear,] <- rep(matTemp, each = fyear)
    
    slxTemp <- get_slx(type=selC_typ, par=selC, laa=laaTemp)
    slxC[1:fyear,] <- rep(matTemp, each = fyear)
    
    # calculate recruits in year y based on the SSB in years previous
    # (depending on the lag) and temperature (forget time lag here)
    SSB[1:fyear] <- sum(J1N[1:fyear,] * 
                            mat[1:fyear,] * waa[1:fyear,])

    CN[1:fyear,] <- get_catch(F_full=F_full[1:fyear], M=init_M, 
                                N=J1N[1:fyear,], selC=slxC[1:fyear,]) + 1e-3

  })

    # Determine the F for the rest of the burn-in period based on the
    # calculation of Fmsy and the proportion given in the parameter file.
  out <- within(stock, {  
    stockT<-stock
    stockT$R_mis<-FALSE
    burnFmsy <- get_burnF(stockT)
    burnFmean <- burnFmsyScalar * burnFmsy
    F_full[(fyear+1):fmyearIdx] <- rlnorm(fmyearIdx - (fyear+1)+1, 
                                              log(burnFmean), burnFsd)
    
    
  })
  return(out)
  
}





