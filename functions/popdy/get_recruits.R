
#' @title Recruitment functions
#' @description Returns recruits, can include an AR1 process if desired (for this option must provide level of correlation, previous year's observed and expected values for the residual).
#'
#' @param type A string indicating the method used to generate recruits, options include:
#' \itemize{
#'   \item{"BH" - Timeseries implementation of the Beverton Holt model (i.e. includs autocorrelative component)}
#'   \item{"BHSteep" - Steepness version of Beverton Holt model.}
#'   \item{"HS" - AGEPRO implementation of the empirical cumulative distribution function with a linear decline to zero. Recruitment model 21 need to have input of historic recruitment in .csv file in /data/data_raw/AssessmentHistory/ must have same name as stockName use only terminal 20 historic years}
#' }
#' @param type2 
#' @param par A vector of parameters used to generate recruits, dependent on selected type:
#' \itemize{
#'   \item{If type = "BH", par is a matrix with one row and four named columns containing Ricker "a" and "b" parameters, a temperature effect "g", and an autocorrelative component "rho". Vectors of observed and predicted recruitment from prior year are also required arguments.}
#'   \item{IF type = "BHSteep", par is a named vector containing 'beta1', 'beta2', and 'beta3', defaults set to 0. Vector of SSBR at F=0 also required argument.}
#'   \item{If type = "HS", par contains 'SSB_star' which describes the hockey-stick hinge ??? other parameters??? is this also a named matrix???}
#' }
#' @param SSB Thetotal spawning stock size - mature individuals in weight ??? single number??? vector???
#' @param TAnom_y A value for the temperature anomaly in year y.
#' @param pe_R Process error level for recruitment (lognomal scale).
#' @param block ??? doesn't appear to be used in code
#' @param R_ym1 A vector of observed recruitment from the previous year, required when type = "BH", no default.
#' @param Rhat_ym1 A vector of predicted recruitment from the previous year, required when type = "BH", no default.
#' @param stock A storage object for a single species
#' @param R_est  
#' @param SSBR0 A vector??? of SSBR at F=0, required when type = "BHSteep", no default. 
#' 
#' @return A list containing:
#' \itemize{
#'  \item{Rhat}
#'  \item{R}
#' }

get_recruits <- function(type, type2, par, inputSSB, TAnom_y, pe_R, block,
                         R_ym1=NULL, Rhat_ym1=NULL, stockEnv=NULL, R_est){

  if(!type %in% c('BH', 'BHSteep', 'HS')){
    stop(paste('get_recruits: check spelling of R_typ in individual stock 
               parameter file for', stockEnv$stockName))
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
    Rhat <- (par['a']*inputSSB)/(1+(par['b']*inputSSB))*exp(par['g']*TAnom_y)
    Rhat <- Rhat*1000

  }
    
  else if(type == 'BHSteep'){
  
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
      num <- 4 * hPrime * ( inputSSB / (SSBRF0) )
      den <- ( (1 - hPrime) + (5*hPrime - 1) * ( inputSSB / (R0Prime * SSBRF0) ) )
      z <-  num / den * exp(beta3 * TAnom_y)
      return(z)
    })
    

  }
    
    else if (type == 'HS'){ 
      if(stockEnv$stockName=='haddockGB'){
        Rhat <- with(as.list(par),{
          if (type2=="True"){
            #stockEnv <- within(stockEnv, {
            #assess_vals <- get_HistAssess(stock = stockEnv)
            #})
            pred<-remp(1,tail(as.numeric(stockEnv$assess_vals$assessdat$R,20)))
            
          }
          else{
            pred <- remp(1, as.numeric(R_est))
          }
          return(pred)
        })}
      else{
        Rhat <- with(as.list(par),{
          SSBhinge<-SSB_star
          if (type2=="True"){
            #stockEnv <- within(stockEnv, {
            #assess_vals <- get_HistAssess(stock = stockEnv)
            #})
            
            if (inputSSB >= SSBhinge) {
              pred <- cR * remp(1, tail(as.numeric(stockEnv$assess_vals$assessdat$R), Rnyr))
            } else if (inputSSB < SSBhinge){
              pred <-  cR * (inputSSB/SSBhinge) * remp(1, tail(as.numeric(stockEnv$assess_vals$assessdat$R), Rnyr))
            }
          }
          else{
            if (inputSSB >= SSBhinge) {
              pred <- cR * remp(1, tail(as.numeric(R_est), Rnyr))
            } 
            else if (inputSSB < SSBhinge){
              pred <-  cR * (inputSSB/SSBhinge) * remp(1, tail(as.numeric(R_est), Rnyr))
            }
          }
          return(pred)
        })}
  }
  # Autocorrelation component
  ac <- par['rho'] * log(R_ym1 / Rhat_ym1)
  
  # Random error component
  rc<-rnorm(1,mean=0,sd=pe_R)
  R <- Rhat * exp(ac + rc)
  out <- list(Rhat = unname(Rhat), R = unname(R))

  return(out)
  
  })
}






