

# Function to calculate true FMSY

get_FBRP_true <- function(stock,parenv){
  
  within(stock,{

  #range of F to simulate over
    candF <- seq(from=0, to=1.2, by=0.01)
    yields<- matrix(NA, nrow=50,ncol=length(candF))
    
    for (k in 1:50){
    for (i in 1:121){
    for (j in y:50){

    # calculate length-at-age in year 
    laa <- get_lengthAtAge(type=laa_typ, par=laa_par,
                               ages=fage:page, Tanom=Tanom[y])
    
    # calculate weight-at-age in year y
    waa <- get_weightAtAge(type=waa_typ, par=waa_par,
                               laa=laa, inputUnit='kg')
    
    # calculate maturity in year y
    mat <- get_maturity(type=mat_typ, par=mat_par, laa=laa)
    
    # calculate recruits in year y based on the SSB in years previous
    # (depending on the lag) and temperature
    SSB[j] <- sum(J1N[j-fage,] * mat * waa)
      
    Rout <- get_recruits(type=R_typ, par=Rpar, S=SSB[j], block = 'late',
                           TAnom=Tanom[y], pe_R = pe_R, R_ym1 = R[j-1],
                           Rhat_ym1 = Rhat[j-1])

    R[j] <- Rout[['R']]
    Rhat[j] <- Rout[['Rhat']]
    R[j] <- ifelse(R[y] < 0, 0, R[y])
    
    # calculate the selectivity in year y (changes if the laa changes)
    slxC<- get_slx(type=selC_typ, par=selC, laa=laa)
    slxI <- get_slx(type=selI_typ, par=selI, laa=NULL)
    
    natM <- M

    # calculate what the Jan 1 population numbers are for year y, which
    # depend on the numbers and mortality rate in the previous year and
    # on the recruitment this year

    J1N[j,] <- get_J1Ny(J1Ny0=J1N[j-1,], Zy0=Z[j-1,], R[j])
    
    # calculate the predicted catch in year y, the catch weight and the
    # proportions of catch numbers-at-age. Add small number in case F=0
    CN[j,] <- get_catch(F_full=candF[i], M=natM,
                        N=J1N[j,], selC=slxC) + 1e-3
    
    # get Z for the current year
    Z[j,] <- candF[i]*slxC + natM
    }
    yields[k,i]<-sum(CN[210,]*waa)
    }}
    meanccatches<-colMeans(yields)
    Fmsytrue<-candF[which.max(meanccatches)]
    return(list(Fmsytrue = Fmsytrue))
  })}

