#' @title get_WHAM
#' @description Run Woods Hole Assessment Model (WHAM) executable and produce results object
#' 
#' @param stock
#' @param ... Additional stock parameters used in WHAM setup that are not otherwise specified in the .Dat file
#' 
#' @return

get_WHAM <- function(stock...){
  
  
    # Run the wham model
    #devtools::install_github("timjmiller/wham", dependencies=TRUE, ref="devel")
    #library(wham)
  #source('getUserDLL.R') # loading modified version to resolve DLL conflict when using WHAM- AH & JJ
  #library.dynam.unload(libpath = "/Users/jjesse/AppData/Local/R/win-library/4.2/fishmethods/libs/x64" , chname = "fishmethods_TMBExports") 
  #library.dynam.unload(libpath = "/Users/jjesse/AppData/Local/R/win-library/4.2/fishmethods/libs/x64" , chname = "fishmethods") 
  #library.dynam.unload(libpath = "/Users/jjesse/AppData/Local/R/win-library/4.2/tmvtnorm/libs/x64/" , chname = "fishmethods_TMBExports") 
  #library.dynam.unload(libpath = "/Users/jjesse/AppData/Local/R/win-library/4.2/fishmethods/libs/x64",package="fishmethods",chname = "fishmethods_TMBExports") 
   #library.dynam() 
#print("check DLL")  
#print(getUserDLL)
#stop()
  
  library.dynam(package = 'wham')
  source('fit_wham.R')
  
  
    # Read in saved ASAP .Dat file with wham function based on operating system
  if (Sys.info()['sysname'] == "Windows") {
    wham_dat_file <- read_asap3_dat('assessment/ASAP/ASAP3.dat')
  } else if (Sys.info()['sysname'] == "Linux") {
    wham_dat_file <- read_asap3_dat(paste(rundir, '/ASAP3.dat', sep = ''))
  } 
  
   ###### Urgent questions to finish this piece ??? !!!
  # What pieces of ASAP3.rdat are used elsewhere in MSE framework? - need to make sure we save same info from WHAM & connect those pieces
  # Need to figure out how to add additional arguments to change WHAM setup - also test this
  # Figure out what info we are returning if not the full whamEst object (fit in get_advice) and then update parpop lines for WHAM in get_advice
  # Look at catchability tie-in
  # Update asapEst and res objects for WHAM? Need something to fill this role and either store the same type of information here and have get_WHAM return the same type of information as get_ASAP
    # or update stock to have wham-specific storage (ASAP code copied here but needs updating)
  
  out <- within(stock, {
    #### WHAM settings ####
    if (mproc[m,'ASSESSCLASS'] == 'WHAM') {
      # wham_settings <- list(model_name = "test", selectivity = list(model = c(rep("logistic",2)),
      #                                                               initial_pars = list(c(2,0.4), c(2,0.4)),
      #                                                               fix_pars = list(NULL, c(1,2)))) # !!! add this to the function arguments
      wham_settings <- list(model_name = "test")
      
      }
   # Prepare wham input
  input <- do.call(prepare_wham_input, c(list(asap3 = wham_dat_file), wham_settings)) # need to set up a wham-settings object to pull these from - make it a list so that only list objects that matter get added - only source the wham-settings object once at the start of the file & only if using WHAM
   
   # Fit wham model
   whamEst <- fit_wham(input, do.osa=T, MakeADFun.silent = T)
    
   #save results from wham
   saveRDS(whamEst, file = paste("Assessment/WHAM/", stockName,'_', r, '_', y, '.rdat', sep = '')) #??? probably don't want to save this, save a subset of results 

    
   # Example of convergence check for wham
   check <- check_convergence(whamEst, ret=TRUE) # May want to suppress printing to screen using sink()
   whamConverge <- ifelse((check$na_sdrep == FALSE & check$is_sdrep == TRUE & check$convergence == 0), TRUE, FALSE) # If no NAs in sdrep, hessian invertible and model thinks it is converged (small gradient) then model converged
  

   
    # Read in results
    res <- list(
      waa.fleet= head(waa,1),
      sel.fleet=whamEst$rep$selAA[[1]],
      M=tail(whamEst$rep$MAA,1),
      mat=head(mat,1),
      R=whamEst$rep$NAA[,1],
      SSB=whamEst$rep$SSB,
      J1N=tail(whamEst$rep$NAA,1),
      Fhat= whamEst$rep$F,
      catch = whamEst$rep$pred_catch
    )
    
  }) # Close stock object
  
    # !!! Maybe look at this code to pull together performance metrics/diagnostics to save
  # !!! Look at postprocessing/Plots, and functions/plotResults (auto generated) - get_plots function runs everything, prioritize this
   
  

  return (out)
}