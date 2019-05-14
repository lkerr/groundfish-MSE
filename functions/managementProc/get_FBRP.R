

# Function to calculate F-based reference points
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) columns
#         "FREF_TYP" and "FREF_PAR0". FREF_TYP indicates the type of model
#         that should be used to calculate the F reference point and
#         FREF_PAR0 is the associate F level (e.g., 0.4 for F40% if you are
#         using SPR or 0.1 for F0.1 if you are using YPR. Options for
#         FREF_TYP are:
#     
#     * YPR: yield-per-recruit-based reference point. See get_perRecruit.R.
#            Basically the parameters (par) are just the reference point 
#            level.
#     
#     * SPR: spawning potential ratio-based refence point. See 
#            get_perRecruit.R. Basically the parameters (par) are just the 
#            reference point level.
#            
#     * Mbased: natural mortality-based (data poor) option (see Gabriel and
#               Mace (1999), p.42. In some cases M or some factor of M has
#               been considered as a proxy for Fmsy.
#               
#     
# parpop: named ist of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class.



get_FBRP <- function(parmgt, parpop, parenv, Rfun_lst){
 
  # Load in the recruitment function (recruitment function index is
  # found in the parmgt data frame but the actual functions are from
  # the list Rfun_BmsySim which is created in the processes folder.
  # Necessary for any forecast simulation-based approaches.
  Rfun <- Rfun_BmsySim[[parmgt$RFUN_NM]]
  
  if(parmgt$FREF_TYP == 'YPR' | parmgt$FREF_TYP == 'SPR'){
   
    F <- get_perRecruit(parmgt = parmgt, parpop = parpop)$RPvalue
    
    # If using a per-recruit F-based reference point paired with a forecast
    # simulation B-based reference point you will need an starting-point
    # for the simulation -- calcaulte this assuming fishing at the F-based
    # reference point.
    if(parmgt$BREF_TYP == 'SIM' & parmgt$RFUN_NM == 'forecast'){
      
      # have to use the temporal window set up for the biomass reference
      # point so come up with a dummy parmgt
      parmgtTemp <- parmgt
      parmgtTemp$FREF_PAR0 <- parmgtTemp$BREF_PAR0
      parmgtTemp$FREF_PAR1 <- parmgtTemp$BREF_PAR1
     
      simAtF <- get_proj(type = 'FREF',
                 parmgt = parmgtTemp, 
                 parpop = parpop, 
                 parenv = parenv, 
                 Rfun = Rfun,
                 F_val = F,
                 ny = 200,
                 stReportYr = 2)
  
      # Extract the equilibrium population for use in forecasts for
      # Fmsy forecast calculations and for output for Bmsy forecast
      # calculations
      
      equiJ1N_MSY <- simAtF$J1N
      
    }else{
      equiJ1N_MSY <- NULL
    }
    
  
    return(list(RPvalue = F, equiJ1N_MSY = equiJ1N_MSY))
    
  }else if(parmgt$FREF_TYP == 'FmsySim'){
    
    candF <- seq(from=0, to=1.25, by=0.01)

    # Edit the environmental parameters for the initial run so that
    # the temperature is always the current temperature. Important for
    # temperature-based BRP projections but will not make a difference
    # for hindcast projections. Temperature is length 1 -- the length
    # of the temperature anomaly is tested in get_proj.
    parenvTemp <- parenv
    parenvTemp$Tanom <- rep(parenv$Tanom[parenv$y],
                            times = length(parenv$Tanom))

    simAtF <- lapply(1:length(candF), function(x){
                     get_proj(type = 'FREF',
                              parmgt = parmgt, 
                              parpop = parpop, 
                              parenv = parenvTemp, 
                              Rfun = Rfun,
                              F_val = candF[x],
                              ny = 200,
                              stReportYr = 2)})
    
    sumCW <- do.call(cbind, sapply(simAtF, '[', 'sumCW'))
    
    meanSumCW <- apply(sumCW, 2, mean)
    Fmsy <- candF[which.max(meanSumCW)]
    
    # Extract the equilibrium population (at each level of F) for use in 
    # forecasts for Fmsy forecast calculations and for output for Bmsy 
    # forecast calculations
    equiJ1N_MSY <- sapply(simAtF, '[', 'J1N')
    
    
    # If using forward projection, use the equilibrium values for population
    # size at the current temperature (simAtF) and the optimal F (Fmsy) and 
    # project forward from there. It is important to start from here because 
    # otherwise there might not be enough time in the projection to reach 
    # an equilibrium state.
  
    if(parmgt$RFUN_NM == 'forecast'){
      
      # Get the initial population using the optimal F assuming current
      # temperature anomaly (FMSY)
      
      parpopTemp <- parpop
    
      simAtF <- lapply(1:length(candF), function(x){
        parpopTemp$J1N <- equiJ1N_MSY[[x]]
        get_proj(type = 'FREF',
                 parmgt = parmgt, 
                 parpop = parpopTemp,
                 parenv = parenv, 
                 Rfun = Rfun,
                 F_val = candF[x],
                 stReportYr = 2)})
      
      # Update the optimal states assuming variable temperature
      sumCW <- do.call(cbind, sapply(simAtF, '[', 'sumCW'))
      
      meanSumCW <- apply(sumCW, 2, mean)
      Fmsy <- candF[which.max(meanSumCW)]
      
    }
    
   
    # Warn if maximum yield did not occur within the range
    if(Fmsy %in% range(candF)){
      warning(paste('get_FBRP: maximum yield occurs at endpoint of',
                    'candidate F values'))
    }
    
    # Equilibrium starting conditions at MSY (used in BMSY calculations)
    equiJ1N_MSY <- equiJ1N_MSY[[which.max(meanSumCW)]]
    
    return(list(RPvalue = Fmsy, equiJ1N_MSY = equiJ1N_MSY))
    
  }else if(parmgt$FREF_TYP == 'Fmed'){
    
    slp <- get_replacement(parpop = parpop, parmgt = parmgt)
    pmtemp <- list(FREF_TYP = 'SSBR')
    ssbrGrid <- get_perRecruit(parmgt = pmtemp, parpop = parpop)$PRgrid
    F <- get_fmed(parpop = parpop, rep_slp = slp, ssbrGrid = ssbrGrid)
    
    return(list(RPvalue = F))
    
  }else{
    
    stop('get_FBRP: parmgt FREF_TYP not recognized')
    
  }
  
  
}





