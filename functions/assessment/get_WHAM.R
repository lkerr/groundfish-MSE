#' @title get_WHAM
#' @description Run Woods Hole Assessment Model (WHAM) executable and produce results object
#' 
#' @param stock Data storage object for stock
#' @param ... Additional stock parameters used in WHAM setup that are not otherwise specified in the .Dat file
#' 
#' @return

get_WHAM <- function(stock,...){
  
  library.dynam(package = 'wham')
  
  
    # Read in saved ASAP .Dat file with wham function based on operating system
  if (Sys.info()['sysname'] == "Windows") {
    wham_dat_file <- read_asap3_dat('assessment/ASAP/ASAP3.dat')
  } else if (Sys.info()['sysname'] == "Linux") {
    wham_dat_file <- read_asap3_dat(paste(rundir, '/ASAP3.dat', sep = ''))
  } else { # Other operating systems (e.g. mac)
    wham_dat_file <- read_asap3_dat('assessment/ASAP/ASAP3.dat')
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
    # Pull wham settings for this stock (loaded in runSetup from wham_settings.R)
    stock_wham_settings <- flatten(wham_settings[stockName])
    
    # Prepare wham input
    input <- do.call(prepare_wham_input, c(list(asap3 = wham_dat_file), stock_wham_settings)) # need to set up a wham-settings object to pull these from - make it a list so that only list objects that matter get added - only source the wham-settings object once at the start of the file & only if using WHAM
    
    # Fit wham model
    whamEst <- fit_wham(input, do.osa=F, MakeADFun.silent = TRUE, do.retro = TRUE) # Setting do.osa = TRUE results in "Error in getUserDLL() Multiple TMB models loaded" which is likely an issue with what model TMB is used by make_osa_residuals() - make_osa_resiudals() probably calls TMB::MakeADFun without specifying DLL = "wham"
    #save results from wham
    # saveRDS(whamEst, file = paste("Assessment/WHAM/", stockName,'_', r, '_', y, '.rdat', sep = '')) #??? probably don't want to save this, save a subset of results 
    
    # Convergence check for wham
    check <- check_convergence(whamEst, ret=TRUE) # May want to suppress printing to screen using sink()
    whamConverge <- ifelse((check$na_sdrep == FALSE & check$is_sdrep == TRUE & check$convergence == 0), TRUE, FALSE) # If no NAs in sdrep, hessian invertible and model thinks it is converged (small gradient) then model converged
    
    # Calculate Mohn's rho values
    MohnsRho <- mohns_rho(whamEst)
    
  # Store WHAM results in final MSE output (indexed by stock i, rep r, and year y)
  wham_storage$SSB[[r]][[y]] <- whamEst$rep$SSB 
  wham_storage$F[[r]][[y]] <- whamEst$rep$F
  wham_storage$FAA[[r]][[y]] <- whamEst$rep$FAA_tot
  wham_storage$R[[r]][[y]] <- whamEst$rep$NAA[,1]
  wham_storage$NAA[[r]][[y]] <- whamEst$rep$NAA
  wham_storage$Catch[[r]][[y]] <- c(whamEst$rep$pred_catch) # Not successfully saved in wham_storage for each assessment year
  print("get_WHAM")
  print(y)
  print(wham_storage$Catch[[r]][[y]])
  wham_storage$CAA[[r]][[y]] <- whamEst$rep$pred_CAA[,1,] 
  wham_storage$FMSY[[r]][[y]] <- exp(whamEst$rep$log_FXSPR_static)
  wham_storage$SSBMSY[[r]][[y]] <- exp(whamEst$rep$log_SSB_FXSPR_static)
  wham_storage$MSY[[r]][[y]] <- exp(whamEst$rep$log_Y_FXSPR_static)
  wham_storage$SelAA[[r]][[y]] <- whamEst$rep$selAA
  wham_storage$checkConvergence[[r]][[y]] <- whamConverge
  wham_storage$MohnsRho_SSB[[r]][[y]] <- MohnsRho["SSB"]
  wham_storage$MohnsRho_F[[r]][[y]] <- MohnsRho["Fbar"]
  wham_storage$MohnsRho_R[[r]][[y]] <- MohnsRho["R"]
  wham_storage$MohnsRho_N[[r]][[y]] <- MohnsRho[grep("N", names(MohnsRho))]
  
  # Read in results
  res <- list(
    waa.fleet= matrix(whamEst$input$data$waa[1,1,], nrow = 1), # First row of fleet WAA, !!! only works with a single fleet
    sel.fleet=whamEst$rep$selAA[[1]],
    M=tail(whamEst$rep$MAA,1),
    maturity=whamEst$input$data$mature[nrow(whamEst$input$data$mature),], # Last row of maturity input, !!! only works if maturity constant over time
    R=whamEst$rep$NAA[,1],
    SSB=whamEst$rep$SSB,
    J1N=tail(whamEst$rep$NAA,1),
    F.report= whamEst$rep$F,
    catch = whamEst$rep$pred_catch
  )
  
    # !!! Maybe look at this code to pull together performance metrics/diagnostics to save
  # !!! Look at postprocessing/Plots, and functions/plotResults (auto generated) - get_plots function runs everything, prioritize this
  
  }) # Close stock object

  return (out)
}