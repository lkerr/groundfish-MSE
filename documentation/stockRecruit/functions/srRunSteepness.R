

srRunSteepness <- function(recDat, stock, start, lb, ub, estPar){
  
  # load the TMB package
  invisible(library(TMB))
  
  # Adjust the system path to make sure that R finds the correct compiler
  path0 <- Sys.getenv('PATH')
  path1 <-  paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                   path0)
  Sys.setenv(PATH=path1)
  
  # compile the c++ file and make available to R
  compile('documentation/stockRecruit/srSteepness.cpp')
  dyn.load(dynlib("documentation/stockRecruit/srSteepness"))
  
  
  srDat <- get_SRDat(recDat = recDat, stock = stock)
  
  # Get rid of NAs
  srDat <- srDat[complete.cases(srDat),]
  
  # transfer to traditional-type list and add number of observations
  data <- as.list(srDat)
  data$NOBS <- nrow(srDat)
  data$SSBRF0 <- data$SSBRF0[1] # same for all -- should be scalar
  
  # Short function to unlist and unname. Input values need to be named to
  # ensure that the correct values go in.
  uu <- function(x){
    unname(unlist(x))
  }
  
  # Get parameters and starting values
  parameters <- list(log_h = uu(start['log_h']),
                     log_R0 = uu(start['log_R0']),
                     beta1 = uu(start['beta1']),
                     beta2 = uu(start['beta2']),
                     beta3 = uu(start['beta3']),
                     log_sigR = uu(start['log_sigR']))
  
  # Get bounds
  lb <- list(log_h = uu(lb['log_h']),
             log_R0 = uu(lb['log_R0']),
             beta1 = uu(lb['beta1']),
             beta2 = uu(lb['beta2']),
             beta3 = uu(lb['beta3']),
             log_sigR = uu(lb['log_sigR']))
  
  ub <- list(log_h = uu(ub['log_h']),
             log_R0 = uu(ub['log_R0']),
             beta1 = uu(ub['beta1']),
             beta2 = uu(ub['beta2']),
             beta3 = uu(ub['beta3']),
             log_sigR = uu(ub['log_sigR']))
  
  estPar[estPar == 0] <- NA
  map_par <- as.list(estPar[is.na(estPar)])
  map_par <- lapply(map_par, as.factor)

  obj <- MakeADFun(data = data,
                   parameters = parameters,
                   DLL = "srSteepness",
                   map = map_par)
  
  active_idx <- !names(lb) %in% names(map_par)
  
  # run the model using the R function nlminb()
  opt <- nlminb(start = obj$par, 
                objective = obj$fn, 
                gradient = obj$gr, 
                lower = lb[active_idx], 
                upper = ub[active_idx])
 
  # Generate the sdreport file
  sdrep <- sdreport(obj)
  rep <- obj$report()
  rep$sdrep <- sdrep
  rep$lb <- lb
  rep$ub <- ub
  rep$start <- start
  rep$estPar <- estPar
  rep$SSBRF0 <- data$SSBRF0
  
  return(rep)
}
