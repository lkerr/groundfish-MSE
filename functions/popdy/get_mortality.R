



get_mortality <- function(stock){
  
  
  out <- within(stock, {

    # calculate the predicted catch in year y, the catch weight and the
    # proportions of catch numbers-at-age. Add small number in case F=0
    CN[y,] <- get_catch(F_full=F_full[y], M=natM[y], 
                        N=J1N[y,], selC=slxC[y,]) + 1e-3
    
    
    # get Z for the current year
    Z[y,] <- F_full[y]*slxC[y,] + natM[y]
    
  })
  
  return(out)
  
}









