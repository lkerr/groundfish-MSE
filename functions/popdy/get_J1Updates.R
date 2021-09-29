#Bulk of the OM
get_J1Updates <- function(stock){

  out <- within(stock, {

    # calculate length-at-age in year y
    laa[y,] <- get_lengthAtAge(type=laa_typ, par=laa_par,
                               ages=fage:page, Tanom=Tanom[y])
    # other option here is get_size which tries to take temperature
    # into account. Needs some work there though.

    # calculate weight-at-age in year y
    waa[y,] <- get_weightAtAge(type=waa_typ, par=waa_par,
                               laa=laa[y,], inputUnit='kg',y=y,fmyearIdx=fmyearIdx)

    # calculate maturity in year y
    mat[y,] <- get_maturity(type=mat_typ, par=mat_par, laa=laa[y,],y=y,fmyearIdx=fmyearIdx)

    # calculate recruits in year y based on the SSB in years previous
    # (depending on the lag) and temperature
    SSB[y] <- sum(J1N[y-fage,] * mat[y,] * waa[y-fage,])

    #type2='True' indicates that the recruits will be calculated with the true SRR
    #If hockey-stick function is used, the early block indicates that the last
    #10 years of recruitment will be used in the cumulative distribution function (cdf)
    #The early block is used for 'historical' recruitment. This only matters if the 
    #assessment history is not used for the historical time period. 
    #The late block indicates that the last 20 years of recruitment will be used in
    #the cdf. The late block is used for recruitment during the management procedure
    #period. 
    if (y < fmyearIdx){
    Rout <- get_recruits(type=R_typ, type2='True', par=Rpar, S=SSB[y], block = 'early',
                         TAnom=Tanom[y], pe_R = pe_R, R_ym1 = R[y-1],
                         Rhat_ym1 = Rhat[y-1],R_est=parpop$R)
    }
    if (y >= fmyearIdx){
      Rout <- get_recruits(type=R_typ, type2='True', par=Rpar, S=SSB[y], block = 'late',
                           TAnom=Tanom[y], pe_R = pe_R, R_ym1 = R[y-1],
                           Rhat_ym1 = Rhat[y-1],R_est=parpop$R)
    }
    R[y] <- Rout[['R']]
    Rhat[y] <- Rout[['Rhat']]
    R[y] <- ifelse(R[y] < 0, 0, R[y])

    # calculate the selectivity in year y (changes if the laa changes)
    slxC[y,] <- get_slx(type=selC_typ, par=selC, laa=laa[y,])
    slxI[y,] <- get_slx(type=selI_typ, par=selI, laa=NULL)

    if (y < fmyearIdx){
    natM[y] <- init_M
    }
    else {
      natM[y] <- M
    }

      # option to overwrite calculated values with historic assessment input values for each year
    if (histAssess == TRUE) {
      for(i in 1:nstock){
        if(y %in% assess_vals$assessdat$MSEyr){
        rep_assess <- get_AssessVals()
        F_full[y] <- rep_assess$fish_mort
        R[y] <- rep_assess$rec
        natM[y] <- rep_assess$nat_mort
      }
    }
    }
    for(i in 1:nstock){
      if(y %in% assess_vals$assessdat$MSEyr){
        rep_assess <- get_AssessVals()
        natM[y] <- rep_assess$nat_mort
      }
      browser()
    }
    # calculate what the Jan 1 population numbers are for year y, which
    # depend on the numbers and mortality rate in the previous year and
    # on the recruitment this year
    J1N[y,] <- get_J1Ny(J1Ny0=J1N[y-1,], Zy0=Z[y-1,], R[y])

    # calculate the predicted catch in year y, the catch weight and the
    # proportions of catch numbers-at-age. Add small number in case F=0
    CN[y,] <- get_catch(F_full=F_full[y], M=natM[y],
                        N=J1N[y,], selC=slxC[y,]) + 1e-3

    # get Z for the current year
    Z[y,] <- F_full[y]*slxC[y,] + natM[y]

    # calculate SSB for the current year AEW

    SSB_cur[y] <- sum(J1N[y,] * mat[y,] * waa[y,])

  })

  return(out)

}
