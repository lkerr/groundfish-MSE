


get_caa <- function(stock){
  
  out <- within(stock, {
      
    # # Ensure that TMB will use the Rtools compiler (only windows ... and 
    # # not necessary on all machines)
    # if(platform != 'Linux'){
    #   path0 <- Sys.getenv('PATH')
    #   path1 <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
    #                      path_current)
    #   Sys.setenv(PATH=path1)
    # }
    
    # compile the c++ file and make available to R
    # TMB::compile("assessment/caa.cpp")
    invisible(capture.output(dyn.load(dynlib("assessment/caa"))))
    
    
    
    # whatever is contained in this list (i.e., not commented out) will be an
    # inactive parameter so the starting value will be used.
    map_par <- list(
      log_M = factor(NA),
      # R_dev = factor(rep(NA, ncaayear-1)),
      # log_ipop_mean = factor(NA),
      # ipop_dev = factor(rep(NA, nage)),
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
    
    
    
    # Diagnostics:
    #   (1) plots of observed and predicted values; and
    #   (2) plots of the estimates, true values, starting values, and bounds.
    
    if(FALSE){
      # par(oma=c(0,4,0,0), mfcol=c(2,2), mar=c(0, 0, 0, 0))
      # 
      # plot(rep$obs_sumCW, ylim=range(rep$sumCW, rep$obs_sumCW),
      #      xaxt='n', ann=FALSE, las=1)
      # lines(rep$sumCW)
      # 
      # plot(rep$obs_sumIN, ylim=range(rep$sumIN, rep$obs_sumIN), las=1,
      #      xaxt='n')
      # lines(rep$sumIN)
      # 
      # plot(rep$obs_paaCN[8,],
      #      xaxt='n', yaxt='n', ann=FALSE)
      # lines(rep$paaCN[8,])
      # 
      # plot(rep$obs_paaIN[8,],
      #      xaxt='n', yaxt='n', ann=FALSE)
      # lines(rep$paaIN[8,])
      
      
      par(mfcol=c(1,1), mar=c(4,4,2,1))
      nm <- unique(names(sdrep$par.fixed))
      for(i in 1:length(nm)){
        psv <- parameters[[nm[i]]]
        ptv <- tmb_par_base[[nm[i]]]
        plb <- lb[[nm[i]]]
        pub <- ub[[nm[i]]]
        pev <- sdrep$par.fixed[which(nm[i] == names(sdrep$par.fixed))]
        
        xrg <- c(0,(length(psv)+1))
        yrg <- range(plb, pub)
        plot(NA, xlim=xrg, ylim=yrg, pch=1, main=nm[i], las=1)
        legend('topleft', bty='n', ncol=3, inset=-0.2, xpd=NA,
               legend = c('start', 'true', 'est'),
               col = c('black', 'red', 'blue'),
               pch = c(1, 16, 3))
        segments(x0=1:length(plb), y0=plb, y1=pub, lty=3)
        points(psv, xlim=xrg, ylim=yrg, pch=1)
        points(ptv, pch=16, cex=0.75, col='red')
        points(pev, pch=3, col='blue')
        points(plb, pch=2)
        points(pub, pch=6)
      }
      
    }
  
  })
  
  return(out)

}


#############################
#############################
#############################

# # Testing the dmultinom function in R
# 
# # set of xs, ps and ns. Default n is the sum of the 
# # x vector
# x <- 1:3
# p <- c(8, 4, 3)
# p <- p / sum(p)
# n <- sum(x)
# 
# # writing out the equation versus using the
# # dmultinom function
# log(factorial(n) / prod(factorial(x)) * prod(p^x))
# dmultinom(x=x, p=p, log=TRUE)
# 
# 
# # how to integrate effective sample size? Looks like it
# # works if you just make x into a vector of probabilities
# # instead and then multiply it by n. Basically you are just
# # scaling the xs by whatever you want the effective sample
# # size to be.
# 
# n2 <- 75
# x2 <- x / sum(x)
# 
# -log(factorial(n2) / prod(factorial(x2*n2)) * prod(p^(x2*n2)))
# -dmultinom(x=x2*n2, p=p, log=TRUE)

