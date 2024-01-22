  library(MASS)
  
  #### Set up environment ####
  
  # empty the environment
  rm(list=ls())
  source('processes/runSetup.R')
  
  # if on local machine (i.e., not hpcc) must compile the tmb code
  # (HPCC runs have a separate call to compile this code). Keep out of
  # runSetup.R because it is really a separate process on the HPCC.
  if(runClass != 'HPCC'){
    source('processes/runPre.R', local=ifelse(exists('plotFlag'), TRUE, FALSE))
  }
  
  # source(here("functions/hydra/get_hydra_data_GB_5bin_1978_inpN_noM1.R")) # Baseline
  # source(here("functions/hydra/get_hydra_data_GB_5bin_1978_inpN_noM1_lowB.R")) #Low Biomass
  source(here("functions/hydra/get_hydra_data_GB_5bin_1978_inpN_3gearF.R")) # Three Fleet
  
  source("functions/hydra/mp_functions.R")
  source('functions/hydra/get_hydra.R')
  source('functions/hydra/update_stock_data.R')
  source("functions/hydra/get_f_from_advice.R")
  source('processes/get_assess_results.R')
  source("functions/hydra/read.report.R")
  

  
  ####
  #OM scenario with higher abundance of non-modeled predators (increase M1)
  # change the hydra data file to the below
  # source(here("functions/hydra/get_hydra_data_GB_5bin_1978_inpN_highM1.R"))
  
  ####
  #OM scenario with higher abundance of non-modeled prey (increase other food)
  # change the hydra data file to the below
  # source(here("functions/hydra/get_hydra_data_GB_5bin_1978_inpN_highOF.R"))
  
  ###
  #OM scenario with the price-based fleet dynamics
  # change the input$q and input$ln_fishery_q objects to the price lines currently commented out
  
  ###
  # MP alternative with the other (gear) based complex groupings
  # change the input$complex and input$complexes objects to read in the gear_complexes values
  
  
  #Additional settings and input that may be useful depending on how do_ebfm_mp and
  # get_f_from_advice end up getting used
  
  settings <- list(
    # showTimeSeries = "No",
    useCeiling = "Yes",
    # useCeiling = "No",
    # assessType = "stock complex",
    assessType = "single species",
    pseudoassess = FALSE,
    dynamicRP = FALSE,
    dynamicRPlength=10,
    targetF = 0.75,
    floorB = 0.2, # Default is 0.5
    floorOption = "min status",
    bramp = 0.5,
    blim = 0.1,
    fmin = 0.01,
    floorYrs = 1:40)
  
  #set up some dummy data
  # input <- get_om_pars()
  input <- NULL
  input$Nsp = 10
  #om_long <- run_om(input)
  
  feeding_complexes <- tibble(isp = 1:10,
                              complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
  gear_complexes <- tibble(isp = 1:10,
                           complex = c(1, 3, 3, 1, 1, 3, 1, 2, 1, 2))
  
  # input$complexes <- feeding_complexes
  # input$complex = feeding_complexes$complex
  input$complexes = gear_complexes
  input$complex = gear_complexes$complex
  
   # input$docomplex = TRUE
  input$docomplex = FALSE
  # 
  # ADD A 3 FLEET OPTION FOR THESE
  input$q <- matrix(c(1,0,0,1,1,1,1,1,1,1,
                      0,1,1,0,0,0,0,0,0,0),
                    nrow=2,byrow=TRUE)
  # A way to use the real fleet data 
  input$q <- matrix(c(1,0,0,0.3,0.5,1.5,1,1,0.2,1,
                      0,1,0.33,0,0,0,0,0,0,0),
                    nrow=2,byrow=TRUE)
  input$ln_fishery_q <- c(-1.203972804, -0.693147181, 0.405465108, 0, 0, -1.609437912, 0, -1.108662625)
  
  #price-based q deets
  # input$q <- matrix(c(1,0,0,0.54,0.687,0.572,0.328,0.947,0.125,0.947,
  #                    0,1,3.346,0,0,0,0,0,0,0),
  #                  nrow=2,byrow=TRUE)
  # input$ln_fishery_q <- c(-0.61618614,-0.37590631,-0.55861629,-1.11474167,-0.05480824,-2.07677842,-0.05480824,1.20776560) #price based q
  
  input$forageminimum <- 30
  input$recdevcor <- 0
  
  PlanBstocks <-c("Goosefish", "Silver_hake", "Spiny_dogfish", "Winter_skate", "Yellowtail_flounder")
  ASAPstocks <-c("Atlantic_cod", "Atlantic_herring", "Atlantic_mackerel", "Haddock", "Winter_flounder")
  
  # Option where Haddock and Winter flounder are planB stocks:
  # PlanBstocks <-c("Goosefish", "Haddock","Silver_hake", "Spiny_dogfish", "Winter_flounder","Winter_skate", "Yellowtail_flounder")
  # ASAPstocks <-c("Atlantic_cod", "Atlantic_herring", "Atlantic_mackerel" )
  
  # Option where everything is a planB stock:
  # PlanBstocks <-c("Atlantic_cod", "Atlantic_herring", "Atlantic_mackerel","Goosefish","Haddock", 
  #                 "Silver_hake", "Spiny_dogfish", "Winter_skate", "Yellowtail_flounder","Winter_flounder")
  # ASAPstocks <- c()
  
  for(i in 1:nstock){
    if(stock[[i]]$stockName %in% PlanBstocks) stock[[i]]$planBtrigger <- 0
  }
  
  ####################These are temporary changes for testing ####################
  # econ_timer<-0
  
  #  mproc_bak<-mproc
  #
  # mproc<-mproc_bak[5:5,]
  # nrep<-1
  # nyear <- 45
  # nyear<-200
  ## For each mproc, I need to randomly pull in some simulation data (not quite right. I think I need something that is nrep*nyear long.  Across simulations, each replicate-year gets the same "econ data"
  ####################End Temporary changes for testing ####################
  
  
  #set the rng state based on system time.  Store the random state.
  # if we use a plain old date (seconds since Jan 1, 1970), the number is actually too large, but we can just rebase to seconds since Jan 1, 2018.
  
  start<-Sys.time()-as.POSIXct("2018-01-01 00:00:00", "%Y-%m-%d %H:%M:%S")
  start<-as.double(start)*100
  set.seed(start)
  
  oldseed_ALL <- .Random.seed
  showProgBar<-TRUE
  ####################End Parameter and storage Setup ####################
    #This depends on mproc, fyear, and nyear. So it should be run *after* it is reset. I could be put in the runSetup.R script. But since I'm  adjusting fyear and nyear temporarily, I need it here (for now).
  
  
  source('processes/setupYearIndexing.R')
  
  top_loop_start<-Sys.time()
  
  # Operating model ("real") biomass, catch, and fishing mortality
  OM_Biomass <- list()
  OM_Foragebiomass <- list()
  OM_Catch <- list()
  OM_Fyr <- list()
  # Assessment model error metrics for ASAP, terminal year biomass, F estimate, and recruitment
  AS_TBiomass <- list()
  AS_TF <- list()
  AS_TRec <- list()
  # Management metrics, e.g., the recommended catch and fishing mortality
  MP_Fyr <- list()
  MP_advice <- list()
  MP_results <- list()
  PlanBTriggertot <- list()
  # profvis::profvis({
  # nrep=2
  #### Top rep Loop ####
  for(r in 1:nrep){
    oldseed_mproc <- .Random.seed
    print(paste0("rep # ",r))
    MP_advice_temp <- data.frame(isp=c(),year=c(),advice=c())
    
    MP_results[[r]] <- list()
    AS_TBiomass[[r]] <- list()
    AS_TF[[r]] <-list()
    AS_TRec[[r]] <-list()
    
    #### Top MP loop ####
    for(m in 1:nrow(mproc)){
      
      manage_counter<-0
      
      #Restore the rng state to the value of oldseed_mproc.  For the same values of r, all the management procedures to start from the same RNG state.
      .Random.seed<-oldseed_mproc
      
      bs_temp <- c()
      F_full <- c()
      rec_devs <- c()
      ln_fishery_q <- c()
      newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs,ln_fishery_q=ln_fishery_q)
      
      # This is here for testing:
      # bs_temp <- c(9)
      # F_full <- c(0.1,0.7)
      # rec_devs <- rep(0,10)
      # newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs)
      # END TESTING
      
      
      # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
      # had to call get_hydra outside the loop to add observation error to just the initital time series
      hydraData<- get_hydra(newseed=oldseed_mproc[r],newdata)
      
      # Adds observation error to the original data (before entering MSE)
      hydraData_init_index <- rlnorm(nrow(hydraData$predBiomass),meanlog=log(hydraData$predBiomass[,'predbiomass']),sdlog=hydraData$predBiomass[,'cv'])
      hydraData_init_catch <- rlnorm(nrow(hydraData$predCatch),meanlog=log(hydraData$predCatch[,'predcatch']),sdlog=hydraData$predCatch[,'cv'])
      hydraData_growing_index <- cbind(hydraData$predBiomass,obsbiomass=hydraData_init_index)
      hydraData_growing_catch <- cbind(hydraData$predCatch,obscatch=hydraData_init_catch)
      
      hydradata_growing_catch.df <- data.frame(hydraData_growing_catch[,c(3,4,10)])
      hydradata_growing_catch.df.new <-data.frame(matrix(ncol = 3, nrow = 0))
      # colnames(hydradata_growing_catch.df.new) <- c("year","obscatch","species")
      for(i in 1:input$Nsp){ 
        temp <- dplyr::filter(hydradata_growing_catch.df,species==i) %>% group_by(year) %>% summarise(obscatch = sum(obscatch))
        temp <- cbind(temp,rep(i,nrow(temp)))
        hydradata_growing_catch.df.new <- rbind(hydradata_growing_catch.df.new,temp)
      }
      colnames(hydradata_growing_catch.df.new) <- c("year","obscatch","species")
      # Attach the catch and index data WITH observation error to the hydraData object
      hydraData$IN <- hydraData_growing_index
      hydraData$CN <- hydradata_growing_catch.df.new
      
      MP_advice_temp <- as.data.frame(matrix(nrow=0,ncol=3))
      names(MP_advice_temp) <- c("species","year","advice")
      
      #### Top year loop ####
      for(y in fyear:nyear){
      # for(y in fyear:(fyear+15)){
        source('processes/withinYearAdmin.R')
        begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed) # what exactly is this doing? 
        
  
        AS_TBiomass[[r]][[y]] <- list()
        AS_TF[[r]][[y]] <- list()
        AS_TRec[[r]][[y]] <-list()
        
        if(y >=fmyearIdx){
          # manage_counter<-manage_counter+1 #keeps track of management year
          
          # PULL IN -PREDICTED VALUES- FROM HYDRA DATA
          # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
          hydraData<- get_hydra(oldseed_mproc[r],newdata)
          
          # Adds two objects to hydraData, paaIN and paaCN, the proportions AT AGE of the index and catch
          # GF 06/11/23 adds flag to only generate comp data when MP requires it
          if (settings$assessType == "single species") hydraData<- get_lengthConvert(stock,hydraData)
          
          # Add observation noise but only to the newest year of data, the updates the growing list
          # EMILY: TURN THIS INTO A FUNCTION AND DO IT TO PROPORTIONS AS WELL
          if(length(newdata$bs_temp)>0)
          {
            hydraData_new_index.df <- dplyr::filter(as.data.frame(hydraData$predBiomass),year==max(year))
            hydraData_new_catch.df <- dplyr::filter(as.data.frame(hydraData$predCatch),year==max(year))
            
            hydraData_new_index <- rlnorm(nrow(hydraData_new_index.df),meanlog=log(hydraData_new_index.df[,'predbiomass']),sdlog=hydraData_new_index.df[,'cv'])
            hydraData_new_catch <- rlnorm(nrow(hydraData_new_catch.df),meanlog=log(hydraData_new_catch.df[,'predcatch']),sdlog=hydraData_new_catch.df[,'cv'])
            hydraData_new_index.df <- cbind(hydraData_new_index.df,obsbiomass=hydraData_new_index)
            hydraData_new_catch.df <- cbind(hydraData_new_catch.df,obscatch=hydraData_new_catch)
            
            hydraData_growing_index <- rbind(hydraData_growing_index,hydraData_new_index.df)
            hydraData_growing_catch <- rbind(hydraData_growing_catch,hydraData_new_catch.df)
            
            hydradata_growing_catch.df <- data.frame(hydraData_growing_catch[,c(3,4,10)])
            hydradata_growing_catch.df.new <-data.frame(matrix(ncol = 3, nrow = 0))
            # colnames(hydradata_growing_catch.df.new) <- c("year","obscatch","species")
            for(i in 1:input$Nsp){ 
              temp <- dplyr::filter(hydradata_growing_catch.df,species==i) %>% group_by(year) %>% summarise(obscatch = sum(obscatch))
              temp <- cbind(temp,rep(i,nrow(temp)))
              hydradata_growing_catch.df.new <- rbind(hydradata_growing_catch.df.new,temp)
            }
            colnames(hydradata_growing_catch.df.new) <- c("year","obscatch","species")
            hydradata_growing_catch.df.new %>% relocate(species)
          }
          
          # Attach the catch and index data WITH observation error to the hydraData object
          hydraData$IN <- hydraData_growing_index
          hydraData$CN <- hydradata_growing_catch.df.new # ?? can this be named obs_sumIN and obs_sumCW for stock object??
          
          # Collect index and catch information for all stocks into om_long
          index <- dplyr::filter(as.data.frame(hydraData$IN),survey==1)
          index <- data.frame(t=index$year,type=rep("biomass",nrow(index)),isp=index$species,value=index$obsbiomass)
          index <- as.tibble(index) %>% left_join(input$complexes)
          
          catch <- as.data.frame(as.data.frame(hydraData$CN))
          catch <- data.frame(t=catch$year,type=rep("catch",nrow(catch)),isp=catch$species,value=catch$obscatch)
          catch <- as.tibble(catch) %>% left_join(input$complexes)
          
          om_long <- bind_rows(index, catch)
          
          
          # what does this do?
          end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
          if(showProgBar==TRUE){
            setTxtProgressBar(iterpb, yearitercounter)
          }
          
          # assess_results needs the 4 extra rows (for piscivores, benthivores, planktivores, ecosystem??)
          # for now the assess_results just puts a fixed bmsy msy and fmsy
          
          if(settings$pseudoassess == T)
          {
            assess_results <- run_pseudo_assessments(om_long,refyrs=1:40)
            mp_results <- do_ebfm_mp(settings, assess_results, input)
            # mp_results$out_table %>%
            #  as_tibble()
          }  
          
          if(settings$pseudoassess == F)
          {
            # Single Species Approach
            if(settings$assessType == "single species")
            {
              for(i in 1:nstock){
                stock[[i]] <- update_stock_data(i,hydraData) 
              }
              for(i in 1:nstock){
                stock[[i]] <- get_advice(stock = stock[[i]]) # RUNS MP
              }
    
              for(i in 1:nstock){
                if(y>=fmyearIdx){
                  stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
                }
              }
              
              assess_results <- get_assess_results(stock)
              mp_results <- do_ebfm_mp(settings, assess_results, input)
            
              # Overwrite cfuse in PlanBstocks
              for(i in 1:nstock){
                if(stock[[i]]$stockName %in% ASAPstocks) mp_results$out_table$advice[i] <- mp_results$out_table$cfuse[i]
                if(stock[[i]]$stockName %in% PlanBstocks) mp_results$out_table$advice[i] <- stock[[i]]$gnF$CWrec
              }
              
              # for(i in 1:nstock){
              #   if(stock[[i]]$stockName %in% ASAPstocks){
              #     AS_TBiomass[[r]][[y]][[i]] <- (last(stock[[i]]$res$tot.jan1.B)-last(dplyr::filter(hydraData$biomass,Species==i)$Biomass))/last(dplyr::filter(hydraData$biomass,Species==i)$Biomass)
              #     AS_TF[[r]][[y]][[i]] <- (stock[[i]]$res$Fref$Fcurrent-last(as.numeric(dplyr::filter(hydraData$Fyr,species==i))))/last(as.numeric(dplyr::filter(hydraData$Fyr,species==i)))
              #     AS_TRec[[r]][[y]][[i]] <- (mean(tail(stock[[i]]$res$N.age)[4:6,1])-mean(tail(as.numeric(hydraData$recruitment[i,]))[4:6]))/mean(tail(as.numeric(hydraData$recruitment[i,]))[4:6])
              #   }
              # }
              
              
            }
            
            if(settings$assessType == "stock complex")
            {
              if(settings$dynamicRP==F) assess_results <- run_complex_assessments(om_long, refyrs = 1:40, complex_ids = 1:4) #ref yrs are dummy, can get rid.
              if(settings$dynamicRP==T) assess_results <- run_complex_assessments(om_long, refyrs = (y-settings$dynamicRPlength):y, complex_ids = 1:4) #ref yrs are dummy, can get rid.
              mp_results <- do_ebfm_mp(settings, assess_results, input)
            }
          }
          
          # biomass for the F calculation, replace with something sensible
          # KEEP USING THE REAL OM biomass
          f_calc_biomass <- dplyr::filter(as.data.frame(hydraData$predBiomass),year==max(year), survey==1) %>%
            arrange(species) %>% dplyr::select(predbiomass) %>% t() %>% as.numeric()
           # f_calc_biomass <- c()
           # for(i in 1:10) f_calc_biomass <- c(f_calc_biomass,as.numeric(assess_results$data[[i]][nrow(assess_results$data[[i]]),2]))
          F_full_new <- get_f_from_advice(mp_results$out_table$advice,
                                          f_calc_biomass, 
                                          input$q, 
                                          input$complex, 
                                          input$docomplex)
          
          # if(F_full_new[2]==0) F_full_new[2]<- 0.05
          
          #save the assessment results and MP outcome
          y_store <- y-fyear+1
          to_store <- NULL
          to_store$refs <- mp_results$refs %>% dplyr::select(-data,-results)
          to_store$out_table <- mp_results$out_table
          MP_results[[r]][[y_store]] <- to_store
          
          # Set the new values for the next iteration of MSE
          # F_full is based on the recommended management model output
          # rec_devs are generated using the sigma value from the original hydra data
          # bs_temp is just the average bs_temp from the original data
          # rec_devs_new <- rnorm(hydraData$Nspecies,0,sd=exp(hydraData$ln_recsigma))
          
          # Sigma = matrix(0,nrow=length(hydraData$Nspecies),ncol=length(hydraData$Nspecies))
          Sigma_diag = diag(exp(hydraData$ln_recsigma),nrow=hydraData$Nspecies,ncol=hydraData$Nspecies)
          Sigma_cor = matrix(input$recdevcor,nrow=hydraData$Nspecies,ncol=hydraData$Nspecies)
          diag(Sigma_cor) <- 1 
          Sigma = Sigma_diag %*% Sigma_cor %*% Sigma_diag
          rec_devs_new <- mvrnorm(1,mu=rep(0,hydraData$Nspecies),Sigma=Sigma)


          bs_temp_new <-9.643207
          ln_fishery_q_new <- input$ln_fishery_q
          
          # Update the growing list of new data
          bs_temp <- c(bs_temp,bs_temp_new)
          rec_devs <- c(rec_devs,rec_devs_new)
          F_full <- c(F_full,F_full_new)
          ln_fishery_q <- c(ln_fishery_q, ln_fishery_q_new)
          newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs,ln_fishery_q=ln_fishery_q)
          
          if(settings$assessType == "single species") MP_advice_temp_new <- cbind(species=mp_results$out_table$isp,year=rep(y,length(mp_results$out_table$isp)),advice=mp_results$out_table$advice)
          if(settings$assessType == "stock complex") MP_advice_temp_new <- cbind(species=mp_results$out_table$complex,year=rep(y,length(mp_results$out_table$complex)),advice=mp_results$out_table$advice)
          MP_advice_temp <- rbind(MP_advice_temp,MP_advice_temp_new)
          
        }} #End of year loop 
  
    } #End of mproc loop
  
    # Save the output from this finished MSE:
    # Output the real biomass from the operating model
    OM_Biomass[[r]] <- hydraData$biomass
    OM_Foragebiomass[[r]] <- hydraData$foragebiomass
    # Output the real catch ("predcatch") and observed catch ("obscatch") from the operating model, removing unnecessary columns to save space
    OM_Catch[[r]] <- as.data.frame(hydraData$CN)[,-c(5,6,8,9)]
    OM_Fyr[[r]] <- as.data.frame(hydraData$Fyr)
    MP_Fyr[[r]] <- F_full
    MP_advice[[r]] <- MP_advice_temp
    # Hard coded for now, fix later
    PlanBTriggertot[[r]] <- c(stock[[4]]$planBtrigger,stock[[6]]$planBtrigger,stock[[7]]$planBtrigger,stock[[9]]$planBtrigger,stock[[10]]$planBtrigger)
    
  } #End rep loop
  #})#end profvis
  
  top_loop_end<-Sys.time()
  big_loop<-top_loop_end-top_loop_start
  big_loop
  
  # EML 06/25/23 
  # This commented out section is to look at how well the ASAP models estimate biomass, fishing mortality, recruitment
  # Also wanting to look at the MP_results object
  # if(settings$assessType == "single species")
  # {
  #   AS_TBiomass_matrix <- matrix(nrow=(nyear-fyear+1),ncol=length(stock))
  #   # rownames(AS_TBiomass_matrix)<- fyear:nyear
  #   for(i in fyear:nyear){
  #     for(j in 1:8){
  #       if(!is.null(AS_TBiomass[[1]][[i]][[j]])) AS_TBiomass_matrix[(i-fyear+1),j] <- AS_TBiomass[[1]][[i]][[j]]
  #     }
  #   }
  # 
  #   AS_TF_matrix <- matrix(nrow=(nyear-fyear+1),ncol=length(stock))
    # rownames(AS_TBiomass_matrix)<- fyear:nyear
  #   for(i in fyear:nyear){
  #     for(j in 1:8){
  #       if(!is.null(AS_TF[[1]][[i]][[j]])) AS_TF_matrix[(i-fyear+1),j] <- AS_TF[[1]][[i]][[j]]
  #     }
  #   }
  # 
  #   AS_TRec_matrix <- matrix(nrow=(nyear-fyear+1),ncol=length(stock))
  #   # rownames(AS_TBiomass_matrix)<- fyear:nyear
  #   for(i in fyear:nyear){
  #     for(j in 1:8){
  #       if(!is.null(AS_TRec[[1]][[i]][[j]])) AS_TRec_matrix[(i-fyear+1),j] <- AS_TRec[[1]][[i]][[j]]
  #     }
  #   }
  # }
  
  # MP_results[[2]][[31]]
        # Output run time / date information and OM inputs. The random number is
    # just ensuring that no simulations will be overwritten because the hpcc
    # might finish some in the same second. td is used for uniquely naming the
    # output file as well as for listing in the output results.
  
    td <- as.character(Sys.time())
    td2 <- gsub(':', '', td)
    td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')
  
  
      saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
      saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)
  
  
    for(i in 1:nstock){
      pth <- paste0(ResultDirectory,'/fig/', sapply(stock, '[[', 'stockName')[i])
      dir.create(pth, showWarnings = FALSE)
    }
  
    #### save results ####
      mp_res <- NULL  
      mp_res$biomass <- OM_Biomass  
      mp_res$foragebiomass <- OM_Foragebiomass
      mp_res$catch <- OM_Catch
      mp_res$Fyrspecies <- OM_Fyr
      mp_res$Fyrfleets <- MP_Fyr
      mp_res$catchadvice <- MP_advice
      mp_res$mp_results <- MP_results
      if(settings$assessType == "single species")
      {
        mp_res$biomassRE <- AS_TBiomass
        mp_res$FRE <- AS_TF
        mp_res$RecRE <- AS_TRec
        mp_res$planBtrigger <- PlanBTriggertot
      }
      saveRDS(mp_res, file=paste0(ResultDirectory,'/sim/mpres_', gsub(" ","_",settings$assessType), '.rds'))
      
      #save run options
      run_options <- NULL
      run_options$settings <- settings
      run_options$input <- input
      run_options$assess<-list(PlanB=PlanBstocks, ASAP=ASAPstocks)
     saveRDS(run_options, file=paste0(ResultDirectory,'/sim/options', td2,'.rds'))
      
    omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
    names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
    save(omvalGlobal, file=paste0(ResultDirectory,'/sim/omvalGlobal', td2, '.Rdata'))
  
    if(runClass != 'HPCC'){
      omparGlobal <- readLines('modelParameters/set_om_parameters_global.R')
      cat('\n\nSuccess.\n\n',
          'Completion at: ',
          td,
          file=paste0(ResultDirectory,'/runInfo.txt'))
      cat('\n\n\n\n\n\n\n\n  ##### Global OM Parameters ##### \n\n',
          omparGlobal,
          file=paste0(ResultDirectory,'/runInfo.txt'), sep='\n', append=TRUE)
      for(i in 1:nstock){
        cat('\n\n\n\n\n\n\n\n  ##### Stock OM Parameters ##### \n\n',
            readLines(fileList[i]),
            file=paste0(ResultDirectory,'/runInfo.txt'), sep='\n', append=TRUE)
      }
    }
  
  
  
    if(runClass != 'HPCC'){
      # Note that runPost.R re-sets the containers; results have already been
      # saved however.
      source('processes/runPost.R')
    }
  
  
    print(unique(warnings()))
  
    cat('\n ---- Successfully Completed ----\n')
