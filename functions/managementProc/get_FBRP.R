

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



get_FBRP <- function(parmgt, parpop, parenv, Rfun_lst, stockEnv,y,block){
  # Load in the recruitment function (recruitment function index is
  # found in the parmgt data frame but the actual functions are from
  # the list Rfun_BmsySim which is created in the processes folder.
  # Necessary for any forecast simulation-based approaches.

  m<-1
  Rfun <- Rfun_lst[[parmgt$RFUN_NM]]
  
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
                 stReportYr = 2,
                 stockEnv = stockEnv)

      # Extract the equilibrium population for use in forecasts for
      # Fmsy forecast calculations and for output for Bmsy forecast
      # calculations
      
      equiJ1N_MSY <- simAtF$J1N
      
    }else{
      equiJ1N_MSY <- NULL
    }
    
  
    return(list(RPvalue = F, equiJ1N_MSY = equiJ1N_MSY))
    
  }else if(parmgt$FREF_TYP == 'FmsySim'){
  
    
    ## ---- WHAM MSY inputs you provided (hard-coded here) ----
    # maturity <- parpop$mat
    # 
    # weight <- parpop$waa
    # 
    # selectivity <- parpop$sel
    # # stockEnv$wham_storage$SelF[[r]][[y]]  # ages 6..22 fully selected
    # 
    # M     <- rep(parpop$M,22)
    #   # tail(stockEnv$wham_storage$M[[r]][[y]],22)
    # alpha <- as.numeric(stockEnv$Rpar[['a']])*1000
    #   # tail(stockEnv$wham_storage$alpha[[r]][[y]],1)
    # beta  <- as.numeric(stockEnv$Rpar[['b']])
    # # tail(stockEnv$wham_storage$beta[[r]][[y]],1) 
    # 
    # ## ---- Deterministic equilibrium MSY with WHAM conventions ----
    # eq_msy <- function(maturity, weight, selectivity, M, alpha, beta,
    #                    spawn_frac = 0, F_upper = 1.25, grid_dF = 0.01) {
    #   
    #   stopifnot(length(maturity)==length(weight),
    #             length(weight)==length(selectivity))
    #   A <- length(maturity)
    #   
    #   spr_ypr <- function(F_full) {
    #     Fa <- F_full * selectivity
    #     Za <- Fa + M
    #     
    #     la <- numeric(A)
    #     la[1] <- 1
    #     if (A >= 2) {
    #       for (a in 2:(A-1)) la[a] <- la[a-1] * exp(-Za[a-1])
    #       la[A] <- la[A-1] * exp(-Za[A-1])
    #       la[A] <- la[A] / (1 - exp(-Za[A]))   # geometric plus-group
    #     }
    #     
    #     SPR <- sum(la * weight * maturity)
    #     
    #     Ca  <- (Fa / Za) * (1 - exp(-Za)) * la
    #     YPR <- sum(Ca * weight)
    #     list(SPR = SPR, YPR = YPR)
    #   }
    #   
    #   eq_yield <- function(F_full) {
    #     pry <- spr_ypr(F_full)
    #     SPR <- pry$SPR; YPR <- pry$YPR
    #     if (alpha * SPR <= 1) return(c(Y=0, SSB=0, R=0, SPR=SPR))
    #     R   <- (alpha*SPR - 1) / (beta*SPR)
    #     SSB <- R * SPR
    #     Y   <- R * YPR
    #     c(Y=Y, SSB=SSB, R=R, SPR=SPR)
    #   }
    #   
    #   F_grid <- seq(0, F_upper, by = grid_dF)
    #   out <- vapply(F_grid, eq_yield, numeric(4))
    #   Y   <- out[1,]; SSB <- out[2,]; R <- out[3,]; SPR <- out[4,]
    #   
    #   i <- which.max(Y)
    #   list(F_msy=F_grid[i], MSY=Y[i], SSB_msy=SSB[i], SPR_msy=SPR[i],
    #        curve = data.frame(F=F_grid, Yield=Y, SSB=SSB, SPR=SPR))
    # }
    # 
    # ## ---- Run (spawn at beginning of year: spawn_frac = 0) ----
    # res <- eq_msy(maturity, weight, selectivity, M, alpha, beta, spawn_frac = 0)
    # 
    # cat("\n**Expected (≈ WHAM): F_msy ~ 0.07, MSY ~ 1022.73, SSB_msy ~ 12813, SPR_msy ~ 0.001706**\n")
    # print(with(res, c(F_msy=F_msy, MSY=MSY, SSB_msy=SSB_msy, SPR_msy=SPR_msy)), digits=8)
    # 
    # ## ---- Sanity points at F = 0.07 and F = 0.16 ----
    # checkF <- function(Fval) {
    #   A <- length(maturity)
    #   Fa <- Fval * selectivity
    #   Za <- Fa + M
    #   
    #   la <- numeric(A); la[1] <- 1
    #   for (a in 2:(A-1)) la[a] <- la[a-1] * exp(-Za[a-1])
    #   la[A] <- la[A-1] * exp(-Za[A-1]); la[A] <- la[A] / (1 - exp(-Za[A]))
    #   SPR <- sum(la * exp(-Za * 0) * weight * maturity)
    #   Ca  <- (Fa / Za) * (1 - exp(-Za)) * la
    #   YPR <- sum(Ca * weight)
    #   if (alpha * SPR <= 1) return(c(Y=0, SSB=0, R=0, SPR=SPR))
    #   R   <- (alpha*SPR - 1) / (beta*SPR)
    #   SSB <- R * SPR
    #   Y   <- R * YPR
    #   c(Y=Y, SSB=SSB, R=R, SPR=SPR)
    # }
    # 
    # cat("\nEquilibrium at F=0.07 (should be near Y≈1022.7, SPR≈0.001706):\n")
    # print(checkF(0.07), digits=8)
    # 
    # cat("\nEquilibrium at F=0.16 (should be near Y≈229):\n")
    # print(checkF(0.16), digits=8)
    # 
    # ## ---- Top of the curve (show a few neighbors around F_msy) ----
    # ix <- which.max(res$curve$Yield)
    # rng <- max(1, ix-3):min(nrow(res$curve), ix+3)
    # cat("\nNeighborhood of the maximum:\n")
    # print(res$curve[rng, ], digits=8)
    # 
    candF <- seq(from=0, to=1.25, by=0.01)

    # Edit the environmental parameters for the initial run so that
    # the temperature is always the current temperature. Important for
    # temperature-based BRP projections but will not make a difference
    # for hindcast projections. Temperature is length 1 -- the length
    # of the temperature anomaly is tested in get_proj.
    parenvTemp <- parenv

    simAtF <- lapply(1:length(candF), function(x){
                     get_proj(type = 'FREF',
                              parmgt = parmgt,
                              parpop = parpop,
                              parenv = parenvTemp,
                              Rfun = Rfun,
                              F_val = candF[x],
                              ny = 200,
                              stReportYr = 2,
                              stockEnv = stockEnv,
                              block=block)})

    cat('finished getproj for FBRP')
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
  # 
    if(parmgt$RFUN_NM == 'forecast'){
      
      # Get the initial population using the optimal F assuming current
      # temperature anomaly (FMSY)
      
      parpopTemp <- parpop
      if(exists('y')){
      simAtF <- lapply(1:length(candF), function(x){
        parpopTemp$J1N <- equiJ1N_MSY[[x]]
        get_proj(type = 'FREF',
                 parmgt = parmgt, 
                 parpop = parpopTemp,
                 parenv = parenv, 
                 Rfun = Rfun,
                 F_val = candF[x],
                 stReportYr = 2,
                 stockEnv = stockEnv,
                 block=block)})}

        simAtF <- lapply(1:length(candF), function(x){
          parpopTemp$J1N <- equiJ1N_MSY[[x]]
          get_proj(type = 'FREF',
                   parmgt = parmgt, 
                   parpop = parpopTemp,
                   parenv = parenv, 
                   Rfun = Rfun,
                   F_val = candF[x],
                   stReportYr = 2,
                   stockEnv = stockEnv,
                   block=block)})
      
      # Update the optimal states assuming variable temperature
      sumCW <- do.call(cbind, sapply(simAtF, '[', 'sumCW'))
      
      meanSumCW <- apply(sumCW, 2, mean)
      Fmsy <- candF[which.max(meanSumCW)]
      
    }
    
    # Warn if maximum yield did not occur within the range
    if(Fmsy %in% range(candF)){
      warning(paste0('get_FBRP: maximum yield occurs at endpoint of ',
                     'candidate F values ', '(stock = ',
                     stockEnv$stockName, ')'))
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





