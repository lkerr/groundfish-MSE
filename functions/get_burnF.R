get_burnF <- function(stock){
  Rfun_lst <- Rfun_BmsySim
  parmgt <- list(RFUN_NM = 'forecast',
                 FREF_TYP = 'FmsySim',
                 FREF_PAR0 = length(yrs)-1)
 
  parenv <- list(yrs = yrs, # management years
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
                     Fhat = NA,
                     switch= TRUE)})

 parpopburnF<-parpop
 parpopburnF$Rpar[4]<-'FALSE'
  Fref <- get_FBRP(parmgt = parmgt, parpop = parpopburnF, parenv = parenv, 
                   Rfun_lst = Rfun_lst, stockEnv=stock,y=NULL,block=1)
  
  return(Fref$RPvalue)
}





