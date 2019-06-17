

get_tmbSetup <- function(stock){

 
  out <- within(stock, {

    # Ensure that TMB will use the Rtools compiler (only windows ... and 
    # not necessary on all machines)
    if(platform != 'Linux'){
      path0 <- Sys.getenv('PATH')
      path1 <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                      path_current)
      Sys.setenv(PATH=path1)
    }
    
    
    sty <- y-ncaayear+1
    
    # get the random walk deviations
    R_dev <- get_RWdevs(get_dwindow(R, sty, y))
    
    # get the initial population mean and deviations
    ipopInfo <- get_LMdevs(J1N[sty,] / caaInScalar)
    log_ipop_mean <- ipopInfo$lmean
    ipop_dev <- ipopInfo$lLMdevs
    

    # Translate R_dev_typ to a number
    if(R_dev_typ == 'meanDevs'){
      R_dev_typNum <- 0
    }else if(R_dev_typ == 'randomWalk'){
      R_dev_typNum <- 1
    }else{
      stop('R_dev_typ not recognized')
    }
    
    if(R_dev_temp){
      R_dev_tempNum <- 1
    }else{
      R_dev_tempNum <- 0
    }
    
    tmb_dat <- try(list(
    
                      # index bounds
                      ncaayear = ncaayear,
                      nage = nage,
                      
                      # Catch
                      obs_sumCW = get_dwindow(obs_sumCW, sty, y),
                      obs_paaCN = get_dwindow(obs_paaCN, sty, y),
                    
                      # Index
                      obs_sumIN = get_dwindow(obs_sumIN, sty, y) / caaInScalar,
                      obs_paaIN = get_dwindow(obs_paaIN, sty, y),
                      
                      # Fishing effort
                      obs_effort = get_dwindow(obs_effort, sty, y),
                      
                      # ESS
                      oe_paaCN = oe_paaCN,
                      oe_paaIN = oe_paaIN,
                      
                      # len/wt-at-age
                      laa = get_dwindow(laa, sty, y),
                      waa = get_dwindow(waa, sty, y) * caaInScalar,
                      
                      # Survey info
                      slxI = get_dwindow(slxI, sty, y),
                      timeI = timeI,
                      
                      # Environmental data -- standardized (Z-score)
                      # needs one fewer year because model does not estimate
                      # year 1 recruitment using Rdevs
                      # TAnom_std = c(scale(get_dwindow(Tanom, sty+1, y))),
                      TAnom_std = get_RWdevs(get_dwindow(Tanom, sty, y),
                                             log=FALSE),
                      
                      # Type of Rdevs
                      R_dev_typ = R_dev_typNum,
                      
                      # Match R_devs to temp devs in likelihood?
                      R_dev_tempNum = R_dev_tempNum
    ))
    
    # file.remove('results/caasink.txt')
    # sapply(1:length(tmb_dat), function(x){
    #   # cat(names(tmb_dat[[x]]), '\n', file='results/caasink.txt', append=TRUE)
    #   write.table(tmb_dat[[x]], file='results/caasink.txt', append=TRUE)
    # })
    
    
    
    # Parameters on an arithmetic scale
    tmb_par_arith <- list(M = M,
                          R_dev = R_dev,
                          R_dev_mean = mean(get_dwindow(R, sty, y)),
                          ipop_mean = exp(log_ipop_mean),
                          ipop_dev = ipop_dev,
                          qC = qC,
                          qI = qI,
                          selC = selC,
                          oe_sumCW = oe_sumCW,
                          oe_sumIN = oe_sumIN,
                          # oe_effort = oe_effort,
                          # multiply pe_R by 5 because the deviations used by pe_R 
                          # account only for the random error and are not based on 
                          # a S/R model like they are in the simulation so you need 
                          # extra variance.
                          pe_R = pe_R * 5,
                          slp_Tanom = -1
    )
    
    # Vector indicating whether each of the parameters should be on a log
    # scale or not (1 indicates log scale). Names must match names of
    # tmb_par_arith.
    tmb_par_scale <- c(M = 1, 
                       R_dev = 0, 
                       R_dev_mean = 1,
                       ipop_mean = 1, 
                       ipop_dev = 0, 
                       qC = 1, 
                       qI = 1, 
                       selC = 1, 
                       oe_sumCW = 1, 
                       oe_sumIN = 1, 
                       pe_R = 1,
                       slp_Tanom = 0)
    
    # Check for consistency in tmb_par_arith and tmb_par_scale
    if(any(names(tmb_par_arith) != names(tmb_par_scale))){
      stop('get_tmb_setup: names(tmb_par_arith) != names(tmb_par_scale)')
    }
    
    # Apply log function to those parameters that should be logged
    tmb_par <- mapply(FUN = function(x,y)
                              if(y == 1){
                                return(log(x))
                              }else{
                                return(x)
                            }, 
                      tmb_par_arith, tmb_par_scale)
    
    names(tmb_par) <- sapply(1:length(tmb_par), 
                             function(x) ifelse(tmb_par_scale[x],
                                                paste0('log_', names(tmb_par)[x]),
                                                names(tmb_par)[x]))


    # tmb_par will be used, although starting values may be altered for
    # the model; base is for an easy comparison to the true values
    # (i.e., tmb_par_base is not used later in the code)
    tmb_par_base <- tmb_par
    
    # get the lower and upper bounds. Be a little careful with value for p --
    # if it is 1.0 (or less) then if you have a positive value it will be bounded
    # to be positive and negative bounded to be negative always which may be
    # an unrealistic constraint (note that these are in log space so this really
    # has to do with parameters that are close to 1.0 like, for instance, survey
    # catchability may be).
    tmb_lb <- mapply(FUN = function(x,y){
                             get_bounds(x = x, 
                                        type = 'lower', 
                                        p = boundRgLev, 
                                        logScale = y)
                           }, 
                     tmb_par_arith, tmb_par_scale)
      
    
    
    tmb_ub <- mapply(FUN = function(x,y){
                             get_bounds(x = x, 
                                        type = 'upper', 
                                        p = boundRgLev, 
                                        logScale = y)
                           }, 
                     tmb_par_arith, tmb_par_scale)
    
    
    names(tmb_lb) <- sapply(1:length(tmb_lb), 
                             function(x) ifelse(tmb_par_scale[x],
                                                paste0('log_', names(tmb_lb)[x]),
                                                names(tmb_lb)[x]))
    
    names(tmb_ub) <- sapply(1:length(tmb_ub), 
                             function(x) ifelse(tmb_par_scale[x],
                                                paste0('log_', names(tmb_ub)[x]),
                                                names(tmb_ub)[x]))
tmb_lb$R_dev <- tmb_lb$R_dev*3    
tmb_ub$R_dev <- tmb_ub$R_dev*3
tmb_ub$ipop_dev <- tmb_ub$ipop_dev*2
tmb_lb$ipop_dev <- tmb_lb$ipop_dev*2
    
    # make any deviations have identical scales across all
    devIdx <- match(c('R_dev', 'ipop_dev'),  names(tmb_lb))
    for(i in 1:length(devIdx)){
      tmb_lb[[devIdx[i]]] <- rep(min(tmb_lb[[devIdx[i]]]), 
                                 length(tmb_lb[[devIdx[i]]]))
      tmb_ub[[devIdx[i]]] <- rep(max(tmb_ub[[devIdx[i]]]), 
                                 length(tmb_ub[[devIdx[i]]]))
    }

  })

  return(out)

}


