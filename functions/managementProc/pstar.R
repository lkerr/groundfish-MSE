#Function to calculate F from the P* HCR
pstar<-function(maxp,relB,parmgtproj,parpopproj,parenv,Rfun,stockEnv,FrefRPvalue){
  # Code adapted from John Wiedenmann
  # Mid Atlantic used a ramped control rule to have the target P* change
  # with biomass relative to SSBmsy
  # maxp is the max P* target above SSBmsy (MAFMC used 0.4 previouly)

  calc_pstar = function(maxp, relB)#function to calculate P* based on SSB/SSBmsy
  {
    if(relB>=1) #at asymptote
    {
      P = maxp
    }
    else if(relB<=0.1)
    {
      P = 0.0
    }
    else
    {
      slope <- (maxp)/(1-0.1)
      inter <- maxp-slope
      P = inter+slope*relB
    }
    return(P)
  }
  
  catchproj<-matrix(ncol=2,nrow=100)#run projections to get median catch at OFL
  for (i in 1:100){
    catchproj[i,]<-get_proj(type = 'current',
                           parmgt = parmgtproj, 
                           parpop = parpopproj, 
                           parenv = parenv, 
                           Rfun = Rfun,
                           F_val = FrefRPvalue,
                           ny = 200,
                           stReportYr = 2,
                           stockEnv = stockEnv)$sumCW
  }
  OFL<-median(catchproj[,1])
  
  P<-calc_pstar(maxp,relB)#calculate P* 
  
  CV<-1# assume a CV of 1
  
  # Calculate what the ABC should be given the target P* 
  calc_ABC <- function(OFL, P, CV)
  {
    # OFL is the median catch by fishing at Flim for the current population
    #Convert CV to sigma for lognormal dist
    sd <- sqrt(log(CV*CV+1))
    #Calculate ABC using inverse of the lognormal dist
    return(qlnorm(P, meanlog = log(OFL), sdlog = sd))
  }
  catch<-calc_ABC(OFL,P,CV)
  
  #Estimate F based on the catch 
  F <- get_estF(catchproj=catch,parmgtproj=parmgtproj,parpopproj=parpopproj,parenv=parenv,Rfun=Rfun,stockEnv=stockEnv)
  return(F)
  
  }