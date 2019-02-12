

srRun <- function(recDat, stock, start, lb, ub, estPar){
  
  # load the TMB package
  invisible(library(TMB))
  
  # Adjust the system path to make sure that R finds the correct compiler
  path0 <- Sys.getenv('PATH')
  path1 <-  paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                   path0)
  Sys.setenv(PATH=path1)
  
  # compile the c++ file and make available to R
  compile('documentation/stockRecruit/sr.cpp')
  dyn.load(dynlib("documentation/stockRecruit/sr"))
  
  
  srDat <- get_SRDat(recDat = recDat, stock = stock)
  
  # Get rid of NAs
  srDat <- srDat[complete.cases(srDat),]
  
  # transfer to traditional-type list and add number of observations
  data <- as.list(srDat)
  data$NOBS <- nrow(srDat)
  
  # Short function to unlist and unname. Input values need to be named to
  # ensure that the correct values go in.
  uu <- function(x){
    unname(unlist(x))
  }
  
  # Get parameters and starting values
  parameters <- list(log_a = uu(start['log_a']),
                     log_b = uu(start['log_b']),
                     c = uu(start['c']),
                     log_sigR = uu(start['log_sigR']))
  
  # Get bounds
  lb <- list(log_a = uu(lb['log_a']),
             log_b = uu(lb['log_b']),
             c = uu(lb['c']),
             log_sigR = uu(lb['log_sigR']))
  
  ub <- list(log_a = uu(ub['log_a']),
             log_b = uu(ub['log_b']),
             c = uu(ub['c']),
             log_sigR = uu(ub['log_sigR']))
  
  estPar[estPar == 0] <- NA
  map_par <- as.list(estPar[is.na(estPar)])
  map_par <- lapply(map_par, as.factor)
  # for(i in 1:length(map_par)){
  #   map_par[[i]] <- as.factor(map_par[[i]])
  # }
# browser()
  obj <- MakeADFun(data = data,
                   parameters = parameters,
                   DLL = "sr",
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
  
  return(rep)
}
