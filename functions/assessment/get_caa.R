get_caa <- function(stock){
  
  out <- within(stock, {
    
    invisible(capture.output(dyn.load(dynlib("assessment/caa"))))
    
    # whatever is contained in this list (i.e., not commented out) will be an
    # inactive parameter so the starting value will be used.
    map_par <- list(
      log_M = factor(NA),
      #R_dev = factor(rep(NA, ncaayear-1)),
      #log_ipop_mean = factor(NA),
      #ipop_dev = factor(rep(NA, nage)),
      # log_qC = factor(NA),
      # log_qI = factor(NA),
      # log_selC = factor(rep(NA, length(selC))),
      log_oe_sumCW = factor(NA),
      log_oe_sumIN = factor(NA),
      log_pe_R = factor(NA)
    )
    
    # map_par <- list() # all parameters active
    
    # Set parameter bounds
    lb <- tmb_lb
    ub <- tmb_ub
    
    # index for active parameter bounds
    # (note that R does not give an error message if the wrong
    # number of parameter bounds are given
    # if having estimation problems parameter bounds are a good
    # place to check)
    active_idx <- !names(lb) %in% names(map_par)
    
    # add any noise to the parameter starting values
    # (note that the impact of the CV also depends on what the level
    # of the bounds is specified at). Only add noise to the active
    # parameters -- don't want to distort the values of the inactive
    # parameters.
    
    for(i in which(active_idx)){
      tmb_par[[i]] <- get_svNoise(tmb_par[[i]],
                                  cv=startCV,
                                  lb=tmb_lb[[i]], ub=tmb_ub[[i]])
    }
    
    data <- tmb_dat
    parameters <- tmb_par
    
    # make an objective function
    obj <- MakeADFun(data = data,
                     parameters = parameters,
                     DLL = "caa",
                     map = map_par,
                     silent = TRUE
    )
    
    # run the model using the R function nlminb()
    opt <- try(nlminb(start=obj$par, 
                      objective=obj$fn, 
                      gradient=obj$gr, 
                      lower=unlist(lb[active_idx]),
                      upper=unlist(ub[active_idx]),
                      control=list(iter.max = 100000,
                                   eval.max = 1000)))
    
    # estimates and standard errors (run after model optimization)
    sdrep <- try(sdreport(obj))
    if(class(sdrep)[1] == 'try-error') browser()
    
    # list of variables exported using REPORT() function in c++ code
    rep <- obj$report()
    
    # Report the gradients for each of the estimated parameters and
    # the maximum gradient
    rep$gradient.fixed <- sdrep$gradient.fixed
    rep$maxGrad <- max(abs(rep$gradient.fixed))
    
    rep_data <- rep[c('obs_sumCW',
                      'obs_paaCN',
                      'obs_sumIN',
                      'obs_paaIN',
                      'obs_effort',
                      'laa',
                      'waa',
                      'slxI',
                      'timeI')]
    
    rep_par <- rep[c('log_M',
                     'R_dev',
                     'log_ipop_mean',
                     'ipop_dev',
                     'oe_sumCW',
                     'oe_sumIN',
                     'log_pe_R',
                     'log_selC',
                     'log_qC',
                     'log_qI')]
    
    rep_NLL <- rep[c('NLL',
                     'NLL_sumCW',
                     'NLL_sumIN',
                     'NLL_R_dev',
                     'NLL_paaCN',
                     'NLL_paaIN')]
    
    d2 <- data.frame(rep$sumCW, rep$sumIN,
                     rep$paaCN, rep$paaIN)
    
    # Re-set the system path to the original
    if(platform != 'Linux'){
      Sys.setenv(PATH=path0)
    }
  
  })
  
  return(out)

}
