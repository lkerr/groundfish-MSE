Rfun_BmsySim <- list(
  
  forecast = function(type, parpop, parenv, SSB, sdR, stockEnv, y, block,...){
    Rpar<-parpop$Rpar
    Rpar['rho'] <- 0
    gr <- get_recruits(type = type, 
                       par = Rpar, 
                       SSB = SSB,
                       pe_R = sdR,
                       R_ym1 = 1, block = block,
                       Rhat_ym1 = 1,
                       y=y)
    return(gr[['Rhat']])
  },
  
  hindcastMean = function(parpop,parmgt,...){
    mean(tail(parpop$R,parmgt$BREF_PAR0))
  },
  
  hindcastSample = function(parpop,...){
    sample(parpop$R, 1)
  }
  
)
