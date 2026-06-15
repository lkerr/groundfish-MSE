



get_mortality <- function(stock){
  
  
  out <- within(stock, {

    # calculate the predicted catch in year y, the catch weight and the
    # proportions of catch numbers-at-age. Add small number in case F=0
    if(nfleet == 2){
      

      comCN[y,] <- get_2fcatch(comF_full = comF_full[y],
                                         recF_full = recF_full[y],
                                         M = natM[y],
                                         N = J1N[y,],
                                         selC = slxC[y,],
                                         selR = slxR[y,],
                                         type = "com") + 1e-3
      
      recCN[y,] <- get_2fcatch(comF_full = comF_full[y],
                                         recF_full = recF_full[y],
                                         M = natM[y],
                                         N = J1N[y,],
                                         selC = slxC[y,],
                                         selR = slxR[y,],
                                         type = "rec") + 1e-3
      
      CN[y,] <- comCN[y,] + recCN[y,]
      
      
      # get Z for the current year
      Z[y,] <- ((comF_full[y]*slxC[y,]) + (recF_full[y]*slxR[y,])) + natM[y]
      
    }else{
    CN[y,] <- get_catch(F_full=F_full[y], M=natM[y], 
                        N=J1N[y,], selC=slxC[y,]) + 1e-3
    
    
    # get Z for the current year
    Z[y,] <- F_full[y]*slxC[y,] + natM[y]
    }
  })
  
  return(out)
  
}









