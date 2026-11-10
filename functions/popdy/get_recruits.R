## recruitment functions

# The function returns the recruits. 
# Includes an AR1 process if desired -- for this option must include both
# the desired level of correlation and the previous year's observed and Rnyr
# expected values (for a residual).

# type: the type of recruitment function
# 
#      *"BH" time series implementation of the Beverton Holt model
#       (i.e., that includes an autocorrelative component)
#       R = a * S / (b + S) * exp(g * TAnom_y) * 
#           exp(rho*(R_ym1-Rhat_ym1) + Rsig);
#       where R_ym1-Rhat_ym1 is the residual from the previous year.
#       par['a']: alpha
#       par['b']: beta
#       par['g']: temperature effect g
#       par['rho']: autocorrelative component rho
#       R_ym1: observed recruitment from previous year
#       Rhat_ym1: predicted recruitment from previous year
#
#      *'HS' AGEPRO implementation of the empirical cummulative 
#       distribution function with linear decline to zero; 
#       need to have input of historic recruitment in .csv file 
#       in /data/data_raw/AssessmentHistory/ must have same name as stockName
#       use only terminal 20 historic years
#       SSB_star: hockey-stick hinge
#
# par: the model parameters (see descriptions of type above). par must
#      be a matrix of four columns with named rows that correspond
#      to the parameter names listed under 'type' above.
# 
# S: the total spawning stock size -- mature individuals in weight
# 
# TAnom_y: value for the temperature anomaly in year y
# 
# pe_R: process error level for recruitment (lognormal scale)
# 
# R_ym1: observed recruitment from previous year
#       
# Rhat_ym1: predicted recruitment from previous year

get_recruits <- function(type, par, SSB, pe_R, block,
                         R_ym1=NULL, Rhat_ym1=NULL, stockEnv=stock, R_est,y){
  
  if(!type %in% c('BH', 'BHSteep', 'HS')){
    stop(paste('get_recruits: check spelling of R_typ in individual stock 
               parameter file for', stockNames[i]))
  }
  
  with(stockEnv, {

  if('rho' %in% names(par)){
    
    # Check that values for rho are between -1 and 1 as they should be for
    # correlations
    if(par['rho'] < -1 || par['rho'] > 1){
      
      stop('Rfun: par[rho] must be between 0 and 1')
      
    }
    
    # Check that if rho is provided the values for the residuals are not
    # null (the default)
    if(is.null(R_ym1) || is.null(Rhat_ym1)){
      
      stop('Rfun: if rho is given R_ym1 and Rhat_ym1 must be provided')
      
    }
    
    # Provide warning message if NAs are encountered
    if(is.na(R_ym1) || is.na(Rhat_ym1)){
      
      warning('Rfun: NA encountered in R_ym1 or Rhat_y-1 -- autocorrelation
               error not included')
      R_ym1 <- 1
      Rhat_ym1 <- 1
      
    }
    
  }else{
    
    # if rho is not provided, then set it to 0.0 and set the residuals to
    # numbers > 0 (they will be cancelled automatically since rho is zero)
    par['rho'] <- 0
    R_ym1 <- 1
    Rhat_ym1 <- 1
    
  }

  if(type == 'BH'){
    Rhat <- (as.numeric(par['a'])*SSB)/(1+(as.numeric(par['b'])*SSB))
    Rhat <- Rhat*1000
    if (block>175 & stock[[1]]$ Rpar_mis[['Rinc']]==TRUE){
      envV<-seq(0.1,2,by=0.1)
      a<-as.numeric(par['a'])+envV[block-175]
      Rhat <- (a*SSB)/(1+(as.numeric(par['b'])*SSB))
      Rhat <- Rhat*1000
    }
  }

  else if (type == 'HS'){ 
    if(stock[[i]]$stockName=='codGOM'){
      Rhat <- with(as.list(par),{
        SSBhinge<-SSB_star
        if (type2=="True"){
          assess_vals <- get_HistAssess(stock = stock[[i]])
          if (SSB >= SSBhinge) {
            pred <- cR * remp(1, tail(as.numeric(assess_vals$assessdat$R), Rnyr))
          } else if (SSB < SSBhinge){
            pred <-  cR * (SSB/SSBhinge) * remp(1, tail(as.numeric(assess_vals$assessdat$R), Rnyr))
          }
        }
        else{
          if (SSB >= SSBhinge) {
            pred <- cR * remp(1, tail(as.numeric(R_est), Rnyr))
          } 
          else if (SSB < SSBhinge){
            pred <-  cR * (SSB/SSBhinge) * remp(1, tail(as.numeric(R_est), Rnyr))
          }
        }
        return(pred)
      })}
      if(stock[[i]]$stockName=='haddockGB' | stock[[i]]$stockName=='petraleBC'){
        Rhat <- with(as.list(par),{
        if (type2=="True"){
          assess_vals <- get_HistAssess(stock = stock[[i]])
          pred<-remp(1, tail(as.numeric(assess_vals$assessdat$R), as.numeric(Rnyr)))
        if (Rinc=='TRUE' & exists('y') && y>175){
          assess_vals <- get_HistAssess(stock = stock[[i]])
          dist<-tail(as.numeric(assess_vals$assessdat$R), as.numeric(Rnyr))
          dist[dist<20000000][sample(1:length(dist[dist<20000000]),min(y-174,length(dist[dist<20000000])))]<-sample(dist[dist>20000000],min(y-174,length(dist[dist<20000000])),replace=TRUE)
          pred<-remp(1, dist)
        }
        }
        else{
          pred<-remp(1, tail(R_est, as.numeric(Rnyr)))
        }
        return(pred)
        })}
  }

  # Autocorrelation component
  ac <- as.numeric(par['rho']) * log(R_ym1 / Rhat_ym1)
  
  # Random error component
  rc<-rnorm(1,mean=0,sd=pe_R)
  R <- Rhat * exp(ac + rc)
  out <- list(Rhat = unname(Rhat), R = unname(R))
  
  return(out)
  
  })
}