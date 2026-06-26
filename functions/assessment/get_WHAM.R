get_WHAM <- function(stock, Tanom,...){
  library.dynam(package = 'wham')
  

  # Determine if using single- or multi-wham, which have different data structures 
  whamversion <- if(unlist(packageVersion("wham"))[1]>1){"multi"}else{"single"}
  
  # Read in saved ASAP .Dat file with wham function based on operating system
  if (Sys.info()['sysname'] == "Windows") {
    
    
    if(nfleet ==2){
      wham_dat_file<-read_asap3_dat(paste('assessment/ASAP/', stock$stockName,"_2Fleet" ,".dat", sep = ''))
    }else{
      wham_dat_file<-read_asap3_dat(paste('assessment/ASAP/', stock$stockName ,".dat", sep = ''))
    }
    
    #### !!!!! 2 fleet not updated for Linux of mac machines !!!!
    
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
    firstYR <- fmyear - ncaayear-1 # First year of assessment
    currentYR <- (fmyear+y-fmyearIdx-1) # Last year of current assessment 
    
    # If ecov specified for the given stock, use only the data through the currentYR of the assessment
    
    # Prepare wham input (no ecov need to be trimmed to current assessment length)
    wham_dat_file[[1]]$dat$year1 <- fmyearIdx - ncaayear
    styear <- fmyearIdx - ncaayear
    
    wham_dat_file[[1]]$dat$n_ages<-nage
    #Change start years below to use moving window
    #dat_file$dat$year1 <- y - ncaayear
    #styear <- y - ncaayear
    
    #end year
    if(mproc[m,'Lag'] == 'TRUE'){
      endyear <- y-2
    }
    else if(mproc[m,'Lag'] == 'FALSE'){
      endyear <- y-1
    }
    
    #number of years in assessment
    N_rows <- length(styear:endyear)
    wham_dat_file[[1]]$dat$n_years <- N_rows
    
    #natural mortality
    wham_dat_file[[1]]$dat$M <- matrix(get_dwindow(natM, styear, endyear), nrow = N_rows, ncol = page)
    
    #maturity-at-age
    wham_dat_file[[1]]$dat$maturity <- matrix(get_dwindow(mat, styear, endyear), nrow = N_rows)
    
    #WAA matrix
    wham_dat_file[[1]]$dat$WAA_mats[[1]] <- matrix(get_dwindow(waa, styear, endyear), nrow = N_rows)
    
    if(nfleet ==2){
      wham_dat_file[[1]]$dat$WAA_mats[[2]] <- matrix(get_dwindow(waa, styear, endyear), nrow = N_rows)
    }
    
    #selectivity block (single block setup)
    wham_dat_file[[1]]$dat$sel_block_assign[[1]] <- rep(1, N_rows)
    
    #selectivity block for 2 fleets, the dat ile should already have two blocks if nfleet = 2 (see lines 12-13)
    if(nfleet == 2){
      wham_dat_file[[1]]$dat$sel_block_assign[[2]] <- rep(2, N_rows)
    }
    
    #selectivity
    wham_dat_file[[1]]$dat$fleet_sel_end_age<-nage
    
    #catch-at-age proportions and sum catch weight
    if(nfleet == 2){ ### com = blcok 1, rec = block 2
      wham_dat_file[[1]]$dat$CAA_mats[[1]] <- cbind(get_dwindow(obs_paacomCN, styear, endyear), get_dwindow(obs_sumcomCW, styear, endyear))
      wham_dat_file[[1]]$dat$CAA_mats[[2]] <- cbind(get_dwindow(obs_paarecCN, styear, endyear), get_dwindow(obs_sumrecCW, styear, endyear))
    }else{
      wham_dat_file[[1]]$dat$CAA_mats[[1]] <- cbind(get_dwindow(obs_paaCN, styear, endyear), get_dwindow(obs_sumCW, styear, endyear))
    }
    
    # discards - need additional rows even if not using
    wham_dat_file[[1]]$dat$DAA_mats[[1]] <- matrix(0, nrow = N_rows, ncol = page + 1)
    
    if(nfleet == 2){
      wham_dat_file[[1]]$dat$DAA_mats[[2]] <- matrix(0, nrow = N_rows, ncol = page + 1)
    }
    
    # release - also need additional rows if not using
    wham_dat_file[[1]]$dat$prop_rel_mats[[1]] <- matrix(0, nrow = N_rows, ncol = page)
    
    if(nfleet == 2){
      wham_dat_file[[1]]$dat$prop_rel_mats[[2]] <- matrix(0, nrow = N_rows, ncol = page)
    }
    
    wham_dat_file[[1]]$dat$index_sel_end_age<-nage
    
    wham_dat_file[[1]]$dat$IAA_mats[[1]] <- cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), rep(oe_sumIN, N_rows), get_dwindow(obs_paaIN, styear, endyear), rep(oe_paaIN, N_rows)) #year, value, CV, by-age, sample size
    
    # testing
    #wham_dat_file[[1]]$dat$IAA_mats[[1]] <- cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), rep(oe_sumIN, N_rows), get_dwindow(obs_paaIN, styear, endyear), rep(80, N_rows)) #year, value, CV, by-age, sample size
    
    # Recruitment CV
    wham_dat_file[[1]]$dat$recruit_cv <- rep(pe_RSA, N_rows)
    
    #catch CV and catch effective sample size
    # !!!!! needs to be updated with rec CVS
    if(mproc[m,'CatchOEMis'] == 'TRUE'){
      ### !! need to be careful here with rec vs com oe when this is turned on !!
      if(nfleet ==2){
        wham_dat_file[[1]]$dat$catch_cv <- matrix(c(rep(oe_sumcomCW_EM, N_rows), rep(oe_sumrecCW_EM, N_rows)), nrow = N_rows, nfleet)
        wham_dat_file[[1]]$dat$catch_Neff <- matrix(c(rep(oe_paacomCN_EM, N_rows), rep(oe_paarecCN_EM, N_rows)), nrow = N_rows, nfleet)
        
      }else{
        wham_dat_file[[1]]$dat$catch_cv <- matrix(oe_sumCW_EM, nrow = N_rows, 1)
        wham_dat_file[[1]]$dat$catch_Neff <- matrix(oe_paaCN_EM, nrow = N_rows, 1)
      }
      
      
    }
    else if(mproc[m,'CatchOEMis'] == 'FALSE'){
      if(nfleet ==2){
        wham_dat_file[[1]]$dat$catch_cv <- matrix(c(rep(oe_sumcomCW, N_rows), rep(oe_sumrecCW, N_rows)), nrow = N_rows, nfleet)
        wham_dat_file[[1]]$dat$catch_Neff <- matrix(c(rep(oe_paacomCN, N_rows), rep(oe_paarecCN, N_rows)), nrow = N_rows, nfleet)
      }else{
        wham_dat_file[[1]]$dat$catch_cv <- matrix(oe_sumCW, nrow = N_rows, 1)
        wham_dat_file[[1]]$dat$catch_Neff <- matrix(oe_paaCN, nrow = N_rows, 1)
      }
    }
    
    #discard CV - need additional years even if not using
    wham_dat_file[[1]]$dat$discard_cv <- matrix(0, nrow = N_rows, nfleet)
    
    
    #discard ESS (even if not using)
    wham_dat_file[[1]]$dat$discard_Neff <- matrix(0, nrow = N_rows, nfleet)
    
    
    
    
    # pull true starting numbers-at-age from OM
    initN <- stock$J1N[styear,]
    wham_dat_file[[1]]$dat$N1_ini <- initN
    
    wham_dat_file[[1]]$dat$q_ini <- qI      
    
    if(nfleet == 2){
      
      wham_dat_file[[1]]$dat$F1_ini[1] <- exp(stock$comF_full[styear]) 
      wham_dat_file[[1]]$dat$F1_ini[2] <- exp(stock$recF_full[styear]) 
      
    }else{
      wham_dat_file[[1]]$dat$F1_ini <- exp(stock$F_full[styear]) ### test this 
    }
    
    # wham_dat_file[[1]]$dat$steepness_ini<-h
    
    if(mproc[m,'Lag'] == 'TRUE'){
      wham_dat_file[[1]]$dat$nfinalyear <- y-1
    }
    else if(mproc[m,'Lag'] == 'FALSE'){
      wham_dat_file[[1]]$dat$nfinalyear <- y
    }
    
    wham_dat_file[[1]]$dat$proj_ini <- c((y), -1, 3, -99, 1)
    # 
    wham_dat_file[[1]]$dat$R_avg_start <- styear
    wham_dat_file[[1]]$dat$R_avg_end <- endyear
    
    
    
    if(mproc[m,'ECOV'] == TRUE){
      
      ecov <- get_WHAMecov(stock_wham_settings)
      
      ecov$mean <- as.matrix(get_dwindow(Tanom, styear, endyear))
      ecov$use_obs = matrix(1, ncol=1, nrow=length(ecov$mean)) # use all obs (=1)
      ecov$year <- styear:endyear
      #!ecov$lag <- stock_wham_settings$ecov$lag
      #!ecov$where <- stock_wham_settings$ecov$where
      stock_wham_settings$ecov <- ecov
    } 
    

    if(mproc[m,'RFUN_NM'] == "hindcastMean"){
      
      stock_wham_settings$basic_info <- c(stock_wham_settings$basic_info, 
                            list(XSPR_R_avg_yrs = tail(1:wham_dat_file[[1]]$dat$n_years, mproc[m,'BREF_PAR0'])))
      
    }
    
    if(mproc[m,'RFUN_NM'] == "hindcastMeanAllyrs"){
      
      stock_wham_settings$basic_info <- c(stock_wham_settings$basic_info, 
                            list(XSPR_R_avg_yrs = 1:wham_dat_file[[1]]$dat$n_years))
      
    }
    
    # calls wham paramaterization set in wham_settings.R  
    input <- do.call(prepare_wham_input, c(list(asap3 = wham_dat_file), stock_wham_settings)) 
    
    
    # for the BRPs in the OM, when RFUN_NM == hindcastMean, the length of the R time series is set by BREF_PAR0
    # to have equal BRP estimation techniques:
    # otherwise, e.g., if RFUN_NM == hindcastMeanAllyrs, WHAM default is used, which is all years of R
    

    
    #### retaining fixed NAA to start, come back to this!!!!! 
    
    if (stock$stockName=='codWGOM'){
      # Fix starting NAA at initial values (OM values)
      
      input$map$log_N1 <- as.factor(matrix(data=rep(NA,9),nrow=1,ncol=9))
      
    }
    
    
    
    
    
    
    # Fit wham model
    whamEst <- fit_wham(input, do.osa=F, MakeADFun.silent = TRUE, do.retro = TRUE,
                        n.peels = 3, do.check=TRUE)

    # Setting do.osa = TRUE results in "Error in getUserDLL() Multiple TMB models loaded" which is likely an issue with what model TMB is used by make_osa_residuals() - make_osa_resiudals() probably calls TMB::MakeADFun without specifying DLL = "wham"
    
    
    # Check if bad parameters were flagges
    badpar <- "badpar" %in% names(whamEst)
    
    # Convergence check for wham
    check <- check_convergence(whamEst, ret=TRUE) # May want to suppress printing to screen using sink()
    whamConverge <- ifelse((check$na_sdrep == FALSE & check$is_sdrep == TRUE & check$convergence == 0), TRUE, FALSE) # If no NAs in sdrep, hessian invertible and model thinks it is converged (small gradient) then model converged
    
    # set flags for file name
    con_flag <- ifelse(whamConverge, "Converged", "Failed")
    bad_flag <- ifelse(badpar, "BadPars", "NoBadPars")
    
    #save results from wham
    saveRDS(whamEst, file = paste(ResultDirectory, "/WHAM_", stockName,'_', r, '_', y, "_", con_flag, "_", bad_flag, '.rdat', sep = '')) #??? probably don't want to save this, save a subset of results 
    
    if(y == fmyearIdx){plot_wham_output(whamEst, dir.main = paste(getwd(),ResultDirectory, sep = "/"))}
    
    # Calculate Mohn's rho values
    MohnsRho<-NA
    MohnsRho <- try(mohns_rho(whamEst))
 
    # !!!! add rec catch output
    
    # Store WHAM results in final MSE output (indexed by stock i, rep r, and year y)
    wham_storage$SSB[[r]][[y]] <- whamEst$rep$SSB 
    wham_storage$F[[r]][[y]] <- exp(whamEst$rep$log_F_tot)
    wham_storage$FAA[[r]][[y]] <- exp(whamEst$rep$log_FAA_tot)
    wham_storage$Catch[[r]][[y]] <- whamEst$rep$pred_catch # Not successfully saved in wham_storage for each assessment year
    wham_storage$FMSY[[r]][[y]] <- exp(whamEst$rep$log_FXSPR_static)
    wham_storage$SSBMSY[[r]][[y]] <- exp(whamEst$rep$log_SSB_FXSPR_static)[1]
    wham_storage$MSY[[r]][[y]] <- exp(whamEst$rep$log_Y_FXSPR_static)[1]
    wham_storage$SelAA[[r]][[y]] <- whamEst$rep$selAA
    wham_storage$checkConvergence[[r]][[y]] <- whamConverge
    wham_storage$MohnsRho_SSB[[r]][[y]] <- MohnsRho$SSB
    wham_storage$MohnsRho_F[[r]][[y]] <- MohnsRho$Fbar
    wham_storage$MohnsRho_N[[r]][[y]] <- MohnsRho$naa[1,,]
    wham_storage$pars_q[[r]][[y]] <- tail(whamEst$rep$q, n=1) # Save only final q estimate, may revise in future but only a single value can be retained or get_fillRepArrays throws an error!!!

    ### some things use different data structures in multi- or single-wham
    if(whamversion == "multi"){
      wham_storage$R[[r]][[y]] <- whamEst$rep$NAA[,,,1]
      wham_storage$R[[r]][[y]] <- whamEst$rep$NAA[,,,1:nage]
      wham_storage$CAA[[r]][[y]] <- whamEst$rep$pred_CAA[1,,]
      
      ####################### Need to figure out ECOV stuff for multi-wham
      
      # save results
 if(nfleet ==1){res <- list(
        FMSY = exp(whamEst$rep$log_FXSPR_static),
        SSBMSY = exp(whamEst$rep$log_SSB_FXSPR_static)[1],
        waa.fleet= matrix(whamEst$input$data$waa[1,1,], nrow = 1), # First row of fleet WAA, !!! only works with a single fleet
        sel.fleet= whamEst$rep$selAA[[1]],
        M=tail(whamEst$rep$MAA[1,,,1],1),  # assumes M is constant across ages and saves the most recent value
        maturity=tail(whamEst$input$data$mature[1,,],1), # Last row of maturity input, !!! only works if maturity constant over time
        R=whamEst$rep$NAA[1,,,1],
        SSB=whamEst$rep$SSB,
        J1N=tail(whamEst$rep$NAA[1,,,1:nage],1),
        F.report= exp(whamEst$rep$log_F_tot),
        catch = whamEst$rep$pred_catch
 )}
      if(nfleet ==2){
        res <- list(
          FMSY = exp(whamEst$rep$log_FXSPR_static),
          SSBMSY = exp(whamEst$rep$log_SSB_FXSPR_static)[1],
          # !!! waa.fleet only for 1 fleet but fleets use same waa so its all the same...?
          waa.fleet= matrix(whamEst$input$data$waa[1,1,], nrow = 1), # First row of fleet WAA, !!! only works with a single fleet
          selC.fleet= whamEst$rep$selAA[[1]],
          selR.fleet= whamEst$rep$selAA[[2]],
          sel.Index = whamEst$rep$selAA[[3]],
          M=tail(whamEst$rep$MAA[1,,,1],1),  # assumes M is constant across ages and saves the most recent value
          maturity=tail(whamEst$input$data$mature[1,,],1), # Last row of maturity input, !!! only works if maturity constant over time
          R=whamEst$rep$NAA[1,,,1],
          SSB=whamEst$rep$SSB,
          J1N=tail(whamEst$rep$NAA[1,,,1:nage],1),
          F.report= exp(whamEst$rep$log_F_tot),
          comF.report= apply(whamEst$rep$FAA[1,,], 1, max),
          recF.report= apply(whamEst$rep$FAA[2,,], 1, max),
          comcatch = whamEst$rep$pred_catch[,1],
          reccatch = whamEst$rep$pred_catch[,2]
        )
      }}

    if(whamversion == "single"){
      wham_storage$R[[r]][[y]] <- whamEst$rep$NAA[,1]
      wham_storage$NAA[[r]][[y]] <- whamEst$rep$NAA[,1:nage]
      wham_storage$CAA[[r]][[y]] <- whamEst$rep$pred_CAA[,1,]
      wham_storage$MohnsRho_SSB[[r]][[y]] <- MohnsRho["SSB"]
      wham_storage$MohnsRho_F[[r]][[y]] <- MohnsRho["Fbar"]
      wham_storage$MohnsRho_N[[r]][[y]] <- MohnsRho[grep("N", names(MohnsRho))]
      
      wham_storage$pars_Ecov_beta[[r]][[y]] <- whamEst$rep$Ecov_beta[3,,1,] # Should pull last row associated with index, may need to be revised in the future!!!
      wham_storage$pars_Ecov_process[[r]][[y]] <- whamEst$rep$Ecov_process_pars
      
      ####################### Need to add res list for single-wham
      }
    
    # !!! Maybe look at this code to pull together performance metrics/diagnostics to save
    # !!! Look at postprocessing/Plots, and functions/plotResults (auto generated) - get_plots function runs everything, prioritize this
    
  }) # Close stock object
  
  return (out)
}