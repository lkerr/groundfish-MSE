# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R)

Rfun_BmsySim <- list(
  
  forecast = function(type, parpop, parenv, SSB, sdR, stockEnv,y,block,...){
    Rpar<-parpop$Rpar
    if (stock[[i]]$R_mis=='TRUE'){
      type<-'BH' 
      Rpar<-parpop$Rpar_mis}
    if (parpop$switch==TRUE){
      type2<-'True'}
    else{type2<-'Est'}
    Rpar['rho'] <- 0
    gr <- get_recruits(type = type, 
                       type2=type2,
                       par = Rpar, 
                       SSB = SSB,
                       pe_R = sdR,
                       R_ym1 = 1, block = block,
                       Rhat_ym1 = 1,
                       R_est=parpop$R, y=y)
    return(gr[['Rhat']])
  },
  
  hindcastMean = function(parpop,parmgt,...){
    mean(tail(parpop$R,parmgt$BREF_PAR0))
  },
  
  hindcastSample = function(Rest,...){
    sample(Rest, 1)
  }
  
)