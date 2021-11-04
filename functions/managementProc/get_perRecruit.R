#' @title Calculate Per-Recruit and Spawning Potential Ratio
#' @description Calculate yield-per-recruit (YPR), spawning biomass-per-recruit (SSBR), or spawning potential ratio (SPR) based on the selected "FREF_TYP" and "FREF_PAR0" parameters. 
#' 
#' The operational component of parmgt for this function are the "FREF_TYP" and "FREF_PAR0" options.
#' @inheritParams get_FBRP
#' @param nage A large number specifying the ages to consider, generally use default = 100. Note that the length of the input vectors do not have to match nage -- the last values in those vectors will be extended out until the vectors are the same length as nage.
#' @param nF A number of fully selected values of fishing mortality to test (i.e. the increment), default = 1000.
#' @param nFrep A number of fully selected values of fishing mortality to report out in the matrix of results (i.e., for plotting a curve), default = 100. Note that the reference points will be calculated based on nF, nFrep is just for the output matrix.
#' 
#' @return A list containing the following:
#' \itemize{
#'   \item{PRgrid - A matrix with a column of Fs assessed as part of reference point calculations (F_full) and associated yields (yvalue)}
#'   \item{RPlevel - The F level used for the reference point, matches "FREF_PAR0" parameter from parmgt argument}
#'   \item{RPvalue - A number describing the F reference point value}
#'   \item{SSBvalue - A number describing the SSB-per-recruit at the reference point}
#' }
#' 
#' @family managementProcedure, regulations
#' 

## The YPR doesn't quite line up exactly with GN's version in his fishmethods
## package. It's close but not quite. This should be resolved.

get_perRecruit <- function(parmgt, 
                           parpop, 
                           nage=100, 
                           nF=1000, 
                           nFrep=100){
  

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
