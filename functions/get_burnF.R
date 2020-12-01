


get_burnF <- function(stock){
  
  
  
  Rfun_lst <- Rfun_BmsySim
  parmgt <- list(RFUN_NM = 'forecast',
                 FREF_TYP = 'FmsySim',
                 FREF_PAR0 = length(yrs)-1,
                 TRPFlag = 0)
 
  parenv <- list(tempY = temp,
                 Tanom = rep(0,length(yrs)),
                 yrs = yrs, # management years
                 yrs_temp = yrs_temp, # temperature years
                 y = 1)
  
  parpop <- with(stock, {
                   list(
                     waa = waa[1,, drop=FALSE], 
                     sel = slxC[1,, drop=FALSE], 
                     M = init_M, 
                     mat = mat[1,, drop=FALSE],
                     R = NA,
                     SSBhat = SSB[1, drop=FALSE],
                     J1N = J1N[1,, drop=FALSE],
                     Rpar = Rpar,
                     Fhat = NA)})


  
  Fref <- get_FBRP(parmgt = parmgt, parpop = parpop, parenv = parenv, 
                   Rfun_lst = Rfun_lst, stockEnv = stock)
  
  return(Fref$RPvalue)
}





