

## recruitment functions

# The function returns the recruits. Currently just BH but easily expanded.
# Includes an AR1 process if desired -- for this option must include both
# the desired level of correlation and the previous year's observed and
# expected values (for a residual).

# type: the type of recruitment function
# 
#      *"BH" time series implementation of the Beverton Holt model
#       (i.e., that includes an autocorrelative component)
#       R = a * S / (b + S) * exp(c * TAnom_y) * 
#           exp(rho*(R_ym1-Rhat_ym1) + Rsig);
#       where R_ym1-Rhat_ym1 is the residual from the previous year.
#       par['a']: Ricker a
#       par['b']: Ricker b
#       par['c']: temperature effect c
#       par['rho']: autocorrelative component rho
#       R_ym1: observed recruitment from previous year
#       Rhat_ym1: predicted recruitment from previous year
#
#      
#      *'HS' AGEPRO implementation of the empirical cummulative 
#       distribution function with linear decline to zero; Recruitment model 21
#       need to have input of historic recruitment in .csv file 
#       in /data/data_raw/AssessmentHistory/ must have same name as stockName
#       use only terminal 20 historic years
#       if SSB >= SSB_star
#       R = cR * remp(1, as.numeric(assess_vals$assessdat$R))
#       if SSB < SSB_star
#       R = cR *SSB/SSB_star * remp(1, as.numeric(assess_vals$assessdat$R))
#       SSB_star: hockey-stick hinge
#       cR: conversion coefficient to absolute numbers
#
#
#      
# par: the model parameters (see descriptions of type above). par must
#      be a matrix of four columns with named rows that correspond
#      to the parameter names listed under 'type' above. Column 1 must
#      be the parameter estimate, column 2 must be the standard error,
#      and columen 3 and 4 must be the lower and upper parameter bounds,
#      respectively. For no parameter uncertainty, set the standard error
#      column equal to zero. If estimates need not be specifically
#      bounded (e.g., temperature coefficient) then use [-Inf,Inf]
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


get_recruits <- function(type, par, SSB, TAnom_y, pe_R, block,
                         R_ym1=NULL, Rhat_ym1=NULL, stockEnv = stock){

  if(!type %in% c('BH', 'BHSteep', 'HS','HSInc','Ricker')){
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
 
    # Expected value
    Rhat <- (par['a']*SSB)/(1+(par['b']*SSB))*exp(par['g']*TAnom_y)
    Rhat <- Rhat*1000

  }else if(type == 'BHSteep'){
  
    # Note that the steepness version of the stock-recruit model requires SSBR
    # at F=0 which is a function of selectivity. Percieved selectivity can
    # change over the course of the time period according to how the assessment
    # model estimates it; however for the predicted recruitment we are only
    # interested in the realized recruitment. Thus we can just use the true
    # selectivity in the model and not worry about the estimated version.
    
    if(is.na(par['beta1'])){
      par['beta1'] <- 0
    }
    if(is.na(par['beta2'])){
      par['beta2'] <- 0
    }
    if(is.na(par['beta3'])){
      par['beta3'] <- 0
    }

    Rhat <- with(as.list(par), {
      # gamma parameterization has to do with fitting model with steepness
      # between 0 and 1. See A. Weston thesis p. 15 Eqns. 5&6.
      gamma <- -0.5 * log( (1 - 0.2) / (h - 0.2) - 1) + beta1* TAnom_y
      hPrime <- 0.2 + (1 - 0.2) / (1 + exp(-2*gamma));
      R0Prime <- R0 * exp(beta2 * TAnom_y)
      num <- 4 * hPrime * ( SSB / (SSBRF0) )
      den <- ( (1 - hPrime) + (5*hPrime - 1) * ( SSB / (R0Prime * SSBRF0) ) )
      z <-  num / den * exp(beta3 * TAnom_y)
      return(z)
    })
    
  
  }
    
  else if (type == 'HS'){ 
    assess_vals <- get_HistAssess(stock = stock[[i]])
    
    Rhat <- with(as.list(par),{
    
      if (block == 'early'){  # how to calculate historic recruitment, use first 10 assessment years
        if (SSB >= SSB_star) {
          pred <- cR * remp(1, head(as.numeric(assess_vals$assessdat$R), 10))    
          
        } else if (SSB < SSB_star){
          pred <-  cR * (SSB/SSB_star) * remp(1, head(as.numeric(assess_vals$assessdat$R), 10))    
          
        }
        
    } else if (block == 'late'){  # how to calculate projected recruitment using last 20 assessment years
    if (SSB >= SSB_star) {
       pred <- cR * remp(1, tail(as.numeric(assess_vals$assessdat$R), Rnyr))

    } else if (SSB < SSB_star){
      pred <-  cR * (SSB/SSB_star) * remp(1, tail(as.numeric(assess_vals$assessdat$R), Rnyr))

    }
    }
    return(pred)
       })

  }
  else if (type == 'HSInc'){ 
    cdf<-read.csv('data/data_raw/AssessmentHistory/haddockGB.csv')$R
    cdf<-cdf[cdf<200000000]
    cdf<-as.numeric(cdf)
    
    if (TAnom_y < 0.5){
      newcdf<-remp(29,cdf)
      add<-rsnorm(100, mean = 706882500, sd = 760716100, xi = 1.5)
      add<-add[add>200000000]
      add<-sample(add,1)
      cdf<-c(newcdf,add)
    }
    else if (TAnom_y > 0.5 & TAnom_y < 0.8){
      newcdf<-remp(9,cdf)
      add<-rsnorm(100, mean = 706882500, sd = 760716100, xi = 0.8)
      add<-add[add>200000000]
      add<-sample(add,1)
      cdf<-c(newcdf,add)
    }
    else if (TAnom_y > 0.8 & TAnom_y < 1.1){
      newcdf<-remp(8,cdf)
      add<-rsnorm(100, mean = 706882500, sd = 760716100, xi = 1.1)
      add<-add[add>200000000]
      add<-sample(add,2)
      cdf<-c(newcdf,add)
    }
    else if (TAnom_y > 1.1){
      newcdf<-remp(7,cdf)
      add<-rsnorm(100, mean = 706882500, sd = 760716100, xi = 1.4)
      add<-add[add>200000000]
      add<-sample(add,3)
      cdf<-c(newcdf,add)
    }
          if (SSB >= par[1]) {
            Rhat <- par[2] * remp(1, cdf)
            
          } else if (SSB < par[1]){
           Rhat <-  par[2] * (SSB/par[1]) * remp(1, cdf)
          }
    }
  else if (type == 'Ricker'){
    Rhat <- (par['a'] * SSB * exp(-par['b'] * SSB) * 
      exp(TAnom_y * par['g']))*1000
  }
  # Autocorrelation component
  ac <- par['rho'] * log(R_ym1 / Rhat_ym1)
  
  # Random error component
  rc <- rnorm(1, mean = 0, sd = pe_R)
  
  R <- Rhat * exp(ac + rc)
  
  out <- list(Rhat = unname(Rhat), R = unname(R))

  return(out)
  
  })
}



# Rpar1 <- c(h = 0.6,
#           R0 = 6.087769e+07,
#           beta3 = 0,
#           SSBRF0 = 0.01972)
# 
# Rpar2 <- c(h = 0.3,
#            R0 = 6.087769e+07,
#            beta3 = 0,
#            SSBRF0 = 0.01972)
# 
# 
# R_typ <- 'BHSteep'
# 
# SSB <- seq(0, 8e6, length.out=100)
# 
# gr1 <- sapply(1:length(SSB), function(x)
#               get_recruits(type = R_typ, 
#                            par = Rpar1, 
#                            SSB = SSB[x], 
#                            TAnom_y = 0, 
#                            pe_R = 0, 
#                            R_ym1=NULL, 
#                            Rhat_ym1=NULL, 
#                            stockEnv = list(a=NA))$Rhat)
# 
# gr2 <- sapply(1:length(SSB), function(x)
#   get_recruits(type = R_typ, 
#                par = Rpar2, 
#                SSB = SSB[x], 
#                TAnom_y = 0, 
#                pe_R = 0, 
#                R_ym1=NULL, 
#                Rhat_ym1=NULL, 
#                stockEnv = list(a=NA))$Rhat)
# 
# xl <- range(SSB)
# yl <- range(gr1, gr2)
# 
# plot(NA, xlim=xl, ylim=yl)
# lines(gr1 ~ SSB, col='red')
# lines(gr2 ~ SSB, col='blue')
# 
# legend('topleft', lty=1, col=c('red', 'blue'),
#        legend=c('rpar1', 'rpar2'))
# 
# 
# 
# 
# SSB <- 1e10
# 
# num1 <- 4 * Rpar1['h'] * ( SSB / (Rpar1['SSBRF0']) )
# den1 <- ( (1 - Rpar1['h']) + (5*Rpar1['h'] - 1) * ( SSB / (Rpar1['R0'] * Rpar1['SSBRF0']) ) )
# q1 <- num1/den1
# 
# num2 <- 4 * Rpar2['h'] * ( SSB / (Rpar2['SSBRF0']) )
# den2 <- ( (1 - Rpar2['h']) + (5*Rpar2['h'] - 1) * ( SSB / (Rpar2['R0'] * Rpar2['SSBRF0']) ) )
# q2 <- num2/den2





