

## The YPR doesn't quite line up exactly with GN's version in his fishmethods
## package. It's close but not quite. This should be resolved.


# Function to return either Yield-per-recruit, Spawning biomass-per-recruit,
# or Spawning potential ratio.
# 
# 
# parmgt: a 1-row data frame of management parameters. The operational
#         component of parmgt for this function is the (1-row) columns
#         "FREF_TYP" and "FREF_PAR0". FREF_TYP indicates the type of model
#         that should be used to calculate the F reference point and
#         FREF_PAR0 is the associate F level (e.g., 0.4 for F40% if you are
#         using SPR or 0.1 for F0.1 if you are using YPR). The options
#         and associated reference points are:
#         
#           * for YPR, the level of slope of the YPR curve that is x% of the
#             origin slope (e.g., par=0.1 for F_0.1)
#     
#           * for SSBR, the desired level of spawner biomass-per-recruit
#      
#           * for SPR, the desired ratio of spawner biomass-per-recruit 
#             relative to the level of spawner biomass-per-recruit at the 
#             origin (e.g., par=0.4 for F_40%)
# 
# parpop: named list of population parameters (vectors) needed for the 
#         simulation including selectivity (sel), weight-at-age (waa),
#         recruitment (R), maturity (mat) and natural mortality (M).
#         Natural mortality can be a vector or a scalar. Vectors have
#         one value per age class. 
# 
# nage: number of ages to consider -- some large number and doesn't really
#       need to be an argument. Note that the length of the input vectors
#       do not have to match nage -- the last values in those vectors will
#       be extended out until the vectors are the same length as nage.
#       
# nF: number of fully selected values of fishing mortality to test (i.e., 
#     the increment)
#     
# nFrep: number of fully selected values of fishing mortality to report out
#        in the matrix of results (i.e., for plotting a curve). Note that
#        the reference points will be calculated based on nF, nFrep is just
#        for the output matrix.






get_perRecruit <- function(parmgt, parpop, 
                           nage=100, nF=1000, nFrep=100){
  

  if(is.null(parpop$mat) & parmgt$FREF_TYP == 'SPR'){
    stop('get_perRecruit: must provide maturity if using SPR')
  }
  
  # If M is not a vector make it a vector
  if(length(parpop$M) == 1){
    parpop$M <- rep(parpop$M, length(parpop$sel))
  }
  
  # potential levels of F for INSIDE the function (i.e., not output)
  F_full <- seq(0, 2, length.out = nF)
  # Initial level for number of recruits
  N_init <- 1
  
  # Adjust input vectors so they match with the number of ages
  # over which the Y/R or SSB/R is being applied.
  sel <- c(c(parpop$sel), rep(tail(c(parpop$sel), 1), nage-length(parpop$sel)))
  waa <- c(c(parpop$waa), rep(tail(c(parpop$waa), 1), nage-length(parpop$waa)))
  if (stock[[1]]$waa_mis==TRUE){
    waa<-c(c(stock[[1]]$waa[1,]), rep(tail(c(parpop$waa), 1), nage-length(parpop$waa)))
    # waamat<-as.matrix(read.csv('data/data_raw/waamatrix.csv'))
    # colnames(waamat)<-NULL
    # waa <- c(c(waamat[1,]), rep(tail(c(parpop$waa), 1), nage-length(parpop$waa)))
    if (waa_mistyp=='high'){
      dat_file$dat$WAA_mats<-t(replicate(N_rows,waa[1,]))+0.0003
    }
  }
  M <- c(c(parpop$M), rep(tail(c(parpop$M), 1), nage-length(parpop$M)))
  mat <- c(c(parpop$mat), rep(tail(c(parpop$mat), 1), nage-length(parpop$mat)))
  if(!is.null(parpop$mat)){
    mat <- c(parpop$mat, rep(tail(parpop$mat, 1), nage-length(parpop$mat)))
  }
 
  # Generate Yield- and SSB-at-age
  Y <- numeric(length(F_full))
  SSB <- numeric(length(F_full))
  for(i in seq_along(Y)){

    # Calculate mortality, survival and catch
    F <- sel * F_full[i]
    Z <- c(0, F[-length(F)] + M[-length(M)])
    N <- N_init * exp(-cumsum(Z))
    C <- sapply(1:length(N), function(x) 
                F[x] / (F[x] + M[x]) * N[x] * (1 - exp(-F[x] - M[x])))

    # calculate yield and ssb over lifetime given the level of
    # fishing mortality
    Y[i] <- C %*% c(waa) # (use c() for proper formatting)
    SSB[i] <- sum(N * waa * mat)
  }

  if(parmgt$FREF_TYP == 'YPR'){
    ## find F(x)
    # get all slopes
    slp <- sapply(2:length(Y), function(i){
                   (Y[i] - Y[i-1]) / (F_full[i] - F_full[i-1])})
    # slope at the origin
    slpo <- slp[1]
    
    # reference slope
    slpr <- parmgt$FREF_PAR0 * slpo
    
    # find the F @ reference slope
    Fref <- F_full[which.min(abs(slp - slpr))]
         
    # SSB / R at the reference point
    SSBatRP <- SSB[which.min(abs(slp - slpr))]
   
    # for outputs
    yvalue <- Y
  }else if(parmgt$FREF_TYP == 'SSBR'){
    
    # find the F @ the specified level of SSB/R. Recall that SSB is the
    # expected SSB over the lifetime of a single individual and that
    # parmgt$FREF_PAR0 still refers to a level of SSB/R because we're in the 
    # realm of F-based reference points. Noting this just because subtracting
    # something that looks like F from something that looks like SSB makes
    # no sense at first blush.
    Fref <- F_full[which.min(abs(SSB - parmgt$FREF_PAR0))]
    
    # SSB / R at the reference point
    SSBatRP <- SSB[which.min(abs(SSB - parmgt$FREF_PAR0))]
      
    # for outputs
    yvalue <- SSB
    
  }else if(parmgt$FREF_TYP == 'SPR'){
  
    # maximum level for SSBR will occur at F[1] where F_full=0
    SSBRmax <- SSB[1]
    
    # ratios of SSBR to maximum SSBR
    SSBR_ratio <- SSB / SSBRmax
    
    # find the F @ the specified level of F_X%
    Fref <- F_full[which.min(abs(SSBR_ratio - parmgt$FREF_PAR0))]

    # SSB / R at the reference point
    SSBatRP <- SSB[which.min(abs(SSBR_ratio - parmgt$FREF_PAR0))]

    # for outputs
    yvalue <- SSBR_ratio
   
  }else{
    
    stop('get_perRecruit: type not recognized')
    
  }
  
  # index for outputs
  oidx <- seq(1, length(Y), by=round(length(Y)/nFrep))
  
  # output the matrix of y/r, ssb/r or spr or and the corresponding values
  # of fully-selected fishing mortality; the reference point level; and the
  # reference point value
  out <- list(PRgrid = matrix(c(F_full[oidx], yvalue[oidx]), ncol=2),
              RPlevel = parmgt$FREF_PAR0,
              RPvalue = Fref,
              SSBvalue = SSBatRP)

  return(out)
  
}





