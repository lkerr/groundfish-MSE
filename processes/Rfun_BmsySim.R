# Recruitment function list for use in the recruitment index column
# of the object mproc (created by the file generateMP.R)

Rfun_BmsySim <- list(
  
  # MEAN = function(parpop, ...) mean(parpop$R),
  
  # L5SAMP = function(parpop, ...) mean(sample(tail(parpop$R), 5)),
  
  # The median temperature for the Bmsy proxy simulations refers to the
  # median temperature between now and 25 years into the future (if there
  # are 25 years available in the series -- otherwise it just uses what is
  # left).
  
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
    },
  
  hindcastMean = function(parpop,parmgt, ...){ # use when a window of R is needed for reference points, length of years set as BREF_PAR0
    
    mean(tail(parpop$R,parmgt$BREF_PAR0))
    
  },
  
  hindcastMeanAllyrs = function(parpop,parmgt, stockEnv,...){ # use when the full time series of R from the management period (note allyears is in reference to the historical assessment and management period and excludes the burn in) is needed for reference points
    
    mean(tail(parpop$R,stockEnv$N_rows)) # N_rows is set in get_wham based on styear and endyear, which encompasses the lag, so this code should execute the correct number of years with or without a lag
    
  },
  
  hindcastSample = function(Rest,...){
    sample(Rest, 1)
  }
  
)
