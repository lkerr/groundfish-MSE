# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R) ??? Unclear to my how this works, why aren't these functions defined elsewhere?


  
  # MEAN = function(parpop, ...) mean(parpop$R),
  
  # L5SAMP = function(parpop, ...) mean(sample(tail(parpop$R), 5)),
  
  # The median temperature for the Bmsy proxy simulations refers to the
  # median temperature between now and 25 years into the future (if there
  # are 25 years available in the series -- otherwise it just uses what is
  # left).
  
#' @title Generate Recruitment Index Using Forecast
  forecast = function(type, parpop, parenv, SSB, TAnom, sdR, stockEnv,...){
    Rpar<-parpop$Rpar
    if (stock[[i]]$R_mis=='TRUE' && exists("y")=='TRUE'){
      type<-parpop$Rpar_mis_typ
      Rpar<-parpop$Rpar_mis}
    if (parpop$switch==TRUE){
      type2<-'True'}
    else{type2<-'Est'}
    
    Rpar['rho'] <- 0
    gr <- get_recruits(type = type, 
                 type2=type2,
                 par = Rpar, 
                 SSB = SSB,
                 TAnom = TAnom,
                 pe_R = sdR,
                 R_ym1 = 1, block = 'late',
                 Rhat_ym1 = 1,
                 R_est=parpop$R)
    
    return(gr[['Rhat']])
    }
  
  
#' @title Generate Recruitment Index Using Hindcast Mean  
  hindcastMean = function(parpop,parmgt, ...){
    mean(tail(parpop$R,parmgt$BREF_PAR0))
  }
  
  
#' @title Generate Recruitment Index Using Hindcast Sample  
  hindcastSample = function(Rest,...){
    sample(Rest, 1)
  }
  

