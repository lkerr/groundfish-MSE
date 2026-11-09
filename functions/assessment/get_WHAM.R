get_WHAM <- function(stock,y,r,wham_storage,...){
  library.dynam(package = 'wham')
  m<-1
    if (stock$stockName=='petraleBC'){
    wham_dat_file <- read_asap3_dat('assessment/ASAP/ASAP3.dat')}
    if (stock$stockName=='codGOM'){
    wham_dat_file<-read_asap3_dat(paste('assessment/ASAP/', stock$stockName, ".dat", sep = ''))}
  
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

    firstYR <- fmyear - ncaayear # First year of assessment
    currentYR <- (fmyear+y-fmyearIdx-1) # Last year of current assessment 

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
      wham_dat_file[[1]]$dat$M <- matrix(mean(get_dwindow(natM, styear, endyear)), nrow = N_rows, ncol = page)
      if (M_mis==TRUE){#If there is a natural mortality missepcification, the stock assessment will assume that M is the value in M_mis_val
        wham_dat_file[[1]]$dat$M <- matrix(M_mis_val, nrow = N_rows, ncol = page)
      }
      
      #maturity-at-age
      wham_dat_file[[1]]$dat$maturity <- matrix(get_dwindow(mat, styear, endyear), nrow = N_rows)

      #WAA matrix
      wham_dat_file[[1]]$dat$WAA_mats[[1]] <-matrix(get_dwindow(waa, styear, endyear), nrow = N_rows)
      
      if(waa_mis==TRUE){
        wham_dat_file[[1]]$dat$WAA_mats<-t(replicate(N_rows,colMeans(waa[160:165,])))
        # waamat<-as.matrix(read.csv('data/data_raw/waamatrix.csv'))
        # colnames(waamat)<-NULL
        # dat_file$dat$WAA_mats <- t(replicate(N_rows,waamat[1,]))
        if (waa_mistyp=='high'){
          wham_dat_file[[1]]$dat$WAA_mats<-t(replicate(N_rows,colMeans(waa[150:155,])))
        }
      }
      
      #selectivity block (single block setup)
      wham_dat_file[[1]]$dat$sel_block_assign[[1]] <- rep(1, N_rows)

      #selectivity
      wham_dat_file[[1]]$dat$fleet_sel_end_age<-nage
      if(stock$stockName=='petraleBC'){
      wham_dat_file[[1]]$dat$sel_ini[[1]]<- matrix(c(c(selC,3,0.5,rep(0,4)),c(rep(-1,2),rep(1,8),rep(-2,12),1,3,rep(0,4)),c(rep(0,22),rep(1,2),rep(0,4)),c(rep(1,24),rep(0,4))),nrow=28,ncol=4)
      wham_dat_file[[1]]$dat$Frep_ages<-c(7,22)
      }

      #catch-at-age proportions and sum catch weight
      wham_dat_file[[1]]$dat$CAA_mats[[1]] <- cbind(get_dwindow(obs_paaCN, styear, endyear), get_dwindow(obs_sumCW, styear, endyear))
      if(gapinage==TRUE){
        df1<-get_dwindow(obs_paaCN, styear, endyear)
        df2<-matrix(0,nrow=N_rows,ncol=nage)
        for (i in seq(1,N_rows,3)){
          df2[i,]<-df1[i,]
        }
        wham_dat_file[[1]]$dat$CAA_mats[[1]] <- cbind(df2, get_dwindow(obs_sumCW, styear, endyear))}
      if(norecentage==TRUE){
        wham_dat_file[[1]]$dat$CAA_mats[[1]][(length(wham_dat_file[[1]]$dat$CAA_mats[[1]][,1])-4):length(wham_dat_file[[1]]$dat$CAA_mats[[1]][,1]),]<-0
      }
      # discards - need additional rows even if not using
      wham_dat_file[[1]]$dat$DAA_mats[[1]] <- matrix(0, nrow = N_rows, ncol = page + 1)

      # release - also need additional rows if not using
      wham_dat_file[[1]]$dat$prop_rel_mats[[1]] <- matrix(0, nrow = N_rows, ncol = page)
      wham_dat_file[[1]]$dat$index_sel_end_age<-nage
      if (stock$stockName=='petraleBC'){
      wham_dat_file[[1]]$dat$index_sel_ini[[1]]<- matrix(c(c(selI,1.5,1,rep(0,4)),c(rep(-1,2),rep(1,3),rep(2,2),rep(-2,15),1,2,rep(0,4)),c(rep(1,22),rep(0,6)),c(rep(1,24),rep(0,4))),nrow=28,ncol=4)
      }
      # #index data; sum index value, observation error, proportions-at-age, sample size

      wham_dat_file[[1]]$dat$IAA_mats[[1]] <- cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), rep(oe_sumIN, N_rows), get_dwindow(obs_paaIN, styear, endyear), rep(oe_paaIN, N_rows)) #year, value, CV, by-age, sample size

      if(gapinage==TRUE){
        df1<-get_dwindow(obs_paaIN, styear, endyear)
        df2<-matrix(0,nrow=N_rows,ncol=nage)
        for (i in seq(1,N_rows,3)){
          df2[i,]<-df1[i,]
        }
        df1<-rep(oe_paaIN, N_rows)
        df3<-rep(0,N_rows)
        for (i in seq(1,N_rows,3)){
          df3[i]<-df1[i]
        }
        wham_dat_file[[1]]$dat$IAA_mats[[1]]<-cbind(seq(styear,endyear), get_dwindow(obs_sumIN, styear, endyear), rep(oe_sumIN, N_rows), df2, df3) #year, value, CV, by-age, sample size
      }
      if(norecentage==TRUE){
        wham_dat_file[[1]]$dat$IAA_mats[[1]][(length(wham_dat_file[[1]]$dat$IAA_mats[[1]][,1])-4):length(wham_dat_file[[1]]$dat$IAA_mats[[1]][,1]),]<-0
      }
      # Recruitment CV
      wham_dat_file[[1]]$dat$recruit_cv <- rep(pe_RSA, N_rows)

      #catch CV
      wham_dat_file[[1]]$dat$catch_cv <- matrix(0.05, nrow = N_rows, 1)
      
      #discard CV - need additional years even if not using
      wham_dat_file[[1]]$dat$discard_cv <- matrix(0, nrow = N_rows, 1)
      
      #catch effective sample size
      wham_dat_file[[1]]$dat$catch_Neff <- matrix(oe_paaCN, nrow = N_rows, 1)
      if(gapinage==TRUE){
        df1<-rep(oe_paaCN, N_rows)
        df3<-rep(0,N_rows)
        for (i in seq(1,N_rows,3)){
          df3[i]<-df1[i]
        }
        wham_dat_file[[1]]$dat$catch_Neff<-matrix(df3, ncol=1)
      }
      if(norecentage==TRUE){
        wham_dat_file[[1]]$dat$catch_Neff[(length(wham_dat_file[[1]]$dat$catch_Neff)-4):length(wham_dat_file[[1]]$dat$catch_Neff),]<-0
      }
      #discard ESS (even if not using)
      wham_dat_file[[1]]$dat$discard_Neff <- matrix(0, nrow = N_rows, 1)

      initN <- get_init(type = initN_type, par = initN_par)

      wham_dat_file[[1]]$dat$N1_ini<-initN

      wham_dat_file[[1]]$dat$F1_ini<-0.001

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

      wham_dat_file[[1]]$dat$q_ini<-qI

      if (stock$stockName=='petraleBC'){
        input <- prepare_wham_input(asap3 = wham_dat_file,selectivity=list(model=rep("age-specific",2),
                                                   fix_pars=list(c(1:3,7:22),c(1:3,7:22))),
                                    # age_comp='multinomial',
                                    recruit_model=3,
                                    age_comp='logistic-normal-pool0',
                                    M = list(mean_model = "estimate-M"),
                                    NAA_re=list(sigma='rec',cor='iid'),
                                    model_name='petraleBC')
        if (FixMRE==TRUE){
          input <- prepare_wham_input(asap3 = wham_dat_file,selectivity=list(model=rep("age-specific",2),
                                                   fix_pars=list(c(1:3,7:22),c(1:3,7:22))),
                                    # age_comp='multinomial',
                                    recruit_model=3,
                                    age_comp='logistic-normal-pool0',
                                    M=list(mean_model='fixed-M',model='constant',re_model=matrix('ar1_y',1,1),est_ages=1),
                                    NAA_re=list(sigma='rec',cor='iid'),
                                    model_name='petraleBC')
        }
        # input$map$Mpars<-factor(rep(NA,length(input$par$Mpars)))
        # input$map$mean_rec_pars<-as.factor(c(1,NA))
        # input$map$Mpars<-as.factor(rep(NA,length(input$map$Mpars)))
        # recruit_pars=c(1170,0.000138)
        #selectivity=list(model=rep("age-specific",2),
         #                fix_pars=list(c(1:2,6:22),c(1:2,6:22))),
        # input <- prepare_wham_input(asap3 = wham_dat_file, selectivity=list(model=rep("logistic",2),initial_pars=list(c(4,0.2),c(4,0.2))),
        #                             age_comp='multinomial',
        #                             # age_comp='logistic-normal-pool0',
        #                             M=list(mean_model='estimate-M',model='constant',est_ages=1),
        #                             recruit_model=3,
        #                             NAA_re=list(sigma='rec',cor='iid'),
        #                             model_name=stock_wham_settings$model_name)
      if(RER=='TRUE'){
        enviro<-rep(0.1,length(88:174))
        if(y>175){
          enviro<-c(enviro,seq(0.1,by=0.1,length.out=(y-175)))
        }
        sdenv<-enviro*0.2
        enviro<-rnorm(length(enviro),mean=enviro,sd=sdenv)
        enviro<-as.data.frame(enviro)
        enviro$sigma<-0.2
        enviro$Year<-wham_dat_file[[1]]$dat$year1:(wham_dat_file[[1]]$dat$year1+wham_dat_file[[1]]$dat$n_years-1)
        ecov<-list(label='EnvR',mean=as.matrix(enviro$enviro),logsigma=as.matrix(log(enviro$sigma)),year=enviro$Year,
                   use_obs=matrix(1,ncol=1,nrow=dim(enviro)[1]), process_model='rw', recruitment_how=matrix('controlling-lag-0-linear',1,1))
        input <- prepare_wham_input(asap3 = wham_dat_file,selectivity=list(model=rep("age-specific",2),
                                                                           fix_pars=list(c(1:3,7:22),c(1:3,7:22))),
                                    # age_comp='multinomial',
                                    recruit_model=3,
                                    age_comp='logistic-normal-pool0',
                                    M = list(mean_model = "estimate-M"),
                                    ecov=ecov,
                                    NAA_re=list(sigma='rec',cor='iid'),
                                    model_name='petraleBC')}
        input$par$log_NAA_sigma[1]<-log(pe_RSA)
        input$map$log_NAA_sigma<-factor(rep(NA,length(input$par$log_NAA_sigma)))
        input$data$waa_pointer_indices<-1
        input$data$waa_pointer_ssb<-1
      if(MRE=='TRUE'){
          enviroM<-(na.omit(stock$natM)/mean(stock$natM,na.rm=T))[89:(length(na.omit(stock$natM))-1)]
          enviroM<-rnorm(length(enviroM),mean=enviroM,sd=rep(0.75,length(enviroM)))
          enviroM<-as.data.frame(enviroM)
          enviroM$sigma<-0.75
          enviroM$Year<-wham_dat_file[[1]]$dat$year1:(wham_dat_file[[1]]$dat$year1+wham_dat_file[[1]]$dat$n_years-1)
          ecov<-list(label='EnvM',mean=as.matrix(enviroM$enviroM),logsigma=as.matrix(log(enviroM$sigma)),year=enviroM$Year,
                     use_obs=matrix(1,ncol=1,nrow=dim(enviroM)[1]), process_model='ar1', M_how=array('lag-0-linear',c(1,1,22,1)))
          input <- prepare_wham_input(asap3 = wham_dat_file, selectivity=list(model=rep("age-specific",2),
                                                                              fix_pars=list(c(1:2,6:22),c(1:2,6:22))),
                                      # age_comp='multinomial',
                                      age_comp='logistic-normal-pool0',
                                      M=list(mean_model='estimate-M',re_model=matrix('ar1_y',1,1),means_map = array(1,dim = c(1,1,22))),
                                      recruit_model=2,
                                      ecov=ecov,
                                      NAA_re=list(sigma='rec',cor='iid'),
                                      model_name='petraleBC')}
      }

      if (stock$stockName=='codGOM'){
        input <- prepare_wham_input(asap3 = wham_dat_file, selectivity=list(model=rep("age-specific",2),
                                                                            initial_pars=list(c(selC),c(selI)),
                                                                            fix_pars=list(c(6:9),c(6:9))),
                                                                            # age_comp='multinomial',
                                                                            # recruit_model=2,
                                                                            model_name='codGOM')
      }
      # input <- prepare_wham_input(asap3 = wham_dat_file[[1]], selectivity=list(model=rep("logistic",2),
      #                                                                     initial_pars=list(c(2,0.3),c(2,0.3))),
      #                                                                     model_name=stock_wham_settings$model_name)
# need to set up a wham-settings object to pull these from - make it a list so that only list objects that matter get added - only source the wham-settings object once at the start of the file & only if using WHAM

    # Fit wham model
    whamEst <- try(fit_wham(input, do.osa=F, MakeADFun.silent = TRUE, do.retro = TRUE,do.check=TRUE))
    # Setting do.osa = TRUE results in "Error in getUserDLL() Multiple TMB models loaded" which is likely an issue with what model TMB is used by make_osa_residuals() - make_osa_resiudals() probably calls TMB::MakeADFun without specifying DLL = "wham"
#save results from wham
    # saveRDS(whamEst, file = paste("Assessment/WHAM/", stockName,'_', r, '_', y, '.rdat', sep = '')) #??? probably don't want to save this, save a subset of results 

    # Convergence check for wham
    check<-NULL
    check <- try(check_convergence(whamEst, ret=TRUE))
    # May want to suppress printing to screen using sink()
    if(is.null(check)){
    whamConverge <- ifelse((check$na_sdrep == FALSE & check$is_sdrep == TRUE & check$convergence == 0), TRUE, FALSE) # If no NAs in sdrep, hessian invertible and model thinks it is converged (small gradient) then model converged
    }else{whamConverge<-FALSE}
    # Calculate Mohn's rho values
    MohnsRho<-NA
    MohnsRho<-try(mohns_rho(whamEst))
    if(class(whamEst)!='try-error'){
    # Store WHAM results in final MSE output (indexed by stock i, rep r, and year y)
    wham_storage$SSB[[r]][[y]] <- whamEst$rep$SSB 
    wham_storage$F[[r]][[y]] <- exp(whamEst$rep$log_F_tot)
    wham_storage$FAA[[r]][[y]] <- exp(whamEst$rep$log_FAA_tot)
    wham_storage$R[[r]][[y]] <- whamEst$rep$NAA[,,,1]
    wham_storage$NAA[[r]][[y]] <- whamEst$rep$NAA[,,,1:nage]
    wham_storage$Catch[[r]][[y]] <- whamEst$rep$pred_catch # Not successfully saved in wham_storage for each assessment year
    wham_storage$CAA[[r]][[y]] <- whamEst$rep$pred_CAA[,1,] 
    wham_storage$FMSY[y] <- tail(exp(whamEst$rep$log_FMSY),1)
    wham_storage$SSBMSY[y] <- tail(exp(whamEst$rep$log_SSB_MSY),1)[,1]
    wham_storage$MSY[y] <- exp(whamEst$rep$log_MSY)[1]
    wham_storage$SelF[[r]][[y]]<-whamEst$rep$selpars[[1]][1,]
    wham_storage$SelAA[[r]][[y]] <- whamEst$rep$selAA
    wham_storage$checkConvergence[y] <- whamConverge
    wham_storage$MohnsRho_SSB[y] <- MohnsRho["SSB"]
    wham_storage$MohnsRho_F[y] <- MohnsRho["Fbar"]
    wham_storage$M[[r]][[y]]<-exp(whamEst$rep$log_M)[,,,1]
    wham_storage$alpha[[r]][[y]]<-exp(whamEst$rep$log_SR_a)
    wham_storage$beta[[r]][[y]]<-exp(whamEst$rep$log_SR_b)
    if (is.na(MohnsRho["SSB"])){
      wham_storage$MohnsRho_R[y] <- NA
    }
    if (!is.na(MohnsRho["SSB"])){
      wham_storage$MohnsRho_R[y] <- MohnsRho$naa[,,1]
    }
    wham_storage$MohnsRho_N[y] <- MohnsRho[grep("N", names(MohnsRho))]
    wham_storage$pars_Ecov_beta[[r]][[y]] <- whamEst$rep$Ecov_beta[3,,1,] # Should pull last row associated with index, may need to be revised in the future!!!
    wham_storage$pars_Ecov_process[[r]][[y]] <- whamEst$rep$Ecov_process_pars
    wham_storage$pars_q[[r]][[y]] <- tail(whamEst$rep$q, n=1) # Save only final q estimate, may revise in future but only a single value can be retained or get_fillRepArrays throws an error!!!

    # Read in results
    res <- list(
      waa.fleet= matrix(whamEst$input$data$waa[1,1,], nrow = 1), # First row of fleet WAA, !!! only works with a single fleet
      sel.fleet=whamEst$rep$selAA[[1]],
      M=tail(whamEst$rep$MAA[,,,1],1),
      maturity=whamEst$input$data$mature[,nrow(whamEst$input$data$mature),], # Last row of maturity input, !!! only works if maturity constant over time
      R=whamEst$rep$NAA[,,,1],
      SSB=whamEst$rep$SSB,
      J1N=tail(whamEst$rep$NAA[,,,1:nage],1),
      F.report= exp(whamEst$rep$log_F_tot),
      catch = whamEst$rep$pred_catch
    )
    }
    # !!! Maybe look at this code to pull together performance metrics/diagnostics to save
    # !!! Look at postprocessing/Plots, and functions/plotResults (auto generated) - get_plots function runs everything, prioritize this
    
  }) # Close stock object
  
  return (out)
}
