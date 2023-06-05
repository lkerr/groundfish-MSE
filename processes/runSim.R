

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

#Additional settings and input that may be useful depending on how do_ebfm_mp and
# get_f_from_advice end up getting used

settings <- list(
  showTimeSeries = "No",
  useCeiling = "Yes",
  assessType = "stock complex",
  #assessType = "single species",
  targetF = 0.75,
  floorB = 0.5,
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

input$complex = feeding_complexes$complex

input$docomplex = TRUE
#input$docomplex = FALSE
input$q <- matrix(c(1,0,0,1,1,1,1,1,1,1,
                    0,1,1,0,0,0,0,0,0,0),
                  nrow=2,byrow=TRUE)
input$q <- matrix(c(1,0,0,0.3,0.5,1.5,1,1,0.2,1,
                    0,1,0.33,0,0,0,0,0,0,0),
                  nrow=2,byrow=TRUE)
PlanBstocks <-c("Goosefish", "Silver_hake", "Spiny_dogfish", "Winter_skate", "Yellowtail_flounder")
ASAPstocks <-c("Atlantic_cod", "Atlantic_herring", "Atlantic_mackerel", "Haddock", "Winter_flounder")

####################These are temporary changes for testing ####################
# econ_timer<-0

#  mproc_bak<-mproc
#
# mproc<-mproc_bak[5:5,]
# nrep<-1
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

True_Biomass <- list()
True_Catch <- list()

nrep <- 5
#### Top rep Loop ####
for(r in 1:nrep){
  oldseed_mproc <- .Random.seed
  print(paste0("rep # ",r))
  
  #### Top MP loop ####
  for(m in 1:nrow(mproc)){

    manage_counter<-0

    #Restore the rng state to the value of oldseed_mproc.  For the same values of r, all the management procedures to start from the same RNG state.
    .Random.seed<-oldseed_mproc
    

    bs_temp <- c()
    F_full <- c()
    rec_devs <- c()
    newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs)
    
    # This is here for testing:
    # bs_temp <- c(9)
    # F_full <- c(0.1,0.7)
    # rec_devs <- rep(0,10)
    # newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs)
    # END TESTING
    
    source('functions/hydra/get_hydra.R')
    # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
    # had to call get_hydra outside the loop to add observation error to just the initital time series
    hydraData<- get_hydra(newseed=oldseed_mproc[r],newdata)
    
    # Adds observation error to the original data (before entering MSE)
    hydraData_init_index <- rlnorm(nrow(hydraData$predBiomass),meanlog=log(hydraData$predBiomass[,'predbiomass']),sdlog=hydraData$predBiomass[,'cv'])
    hydraData_init_catch <- rlnorm(nrow(hydraData$predCatch),meanlog=log(hydraData$predCatch[,'predcatch']),sdlog=hydraData$predCatch[,'cv'])
    hydraData_growing_index <- cbind(hydraData$predBiomass,obsbiomass=hydraData_init_index)
    hydraData_growing_catch <- cbind(hydraData$predCatch,obscatch=hydraData_init_catch)
    
    # Attach the catch and index data WITH observation error to the hydraData object
    hydraData$IN <- hydraData_growing_index
    hydraData$CN <- hydraData_growing_catch
    
    #### Top year loop ####
    #fyear=1
    #nyear=30
    for(y in fyear:nyear){
      
      source('processes/withinYearAdmin.R')
      begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed) # what exactly is this doing? 
      
       if(y >=fmyearIdx){
      # manage_counter<-manage_counter+1 #keeps track of management year
      
      # PULL IN -PREDICTED VALUES- FROM HYDRA DATA
      source('functions/hydra/get_hydra.R')
      # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
      hydraData<- get_hydra(oldseed_mproc[r],newdata)
      
      # Adds two objects to hydraData, paaIN and paaCN, the proportions AT AGE of the index and catch
      hydraData<- get_lengthConvert(stock,hydraData)
      
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
      }
      
      # Attach the catch and index data WITH observation error to the hydraData object
      hydraData$IN <- hydraData_growing_index
      hydraData$CN <- hydraData_growing_catch # ?? can this be named obs_sumIN and obs_sumCW for stock object??
      
      source('functions/hydra/update_stock_data.R')
      # Attach new catch and index data to stock object
      # for(i in 1:nstock){
      for(i in 1:nstock){
        stock[[i]] <- update_stock_data(i,hydraData) 
      }
         
      #### RUN MP ####
        for(i in 1:nstock){
          stock[[i]] <- get_advice(stock = stock[[i]]) # RUNS MP
        }
        
      #### ADD IMPLEMENTATION ERROR ####
          # for(i in 1:nstock){
          #   stock[[i]] <- get_implementationF(type = 'adviceWithError',
          #                                     stock = stock[[i]])
          # } 
      
      # } # end of fishery management has started clause

      # KILL FISH AND MAKE NEW CATCH AND INDEX FOR HYDRA HERE?
      # IS GENERATING NEW CATCH AND INDEX DATA GOING TO BE DEPENDENT ON FISH INTERACTIONS?
        
     # for(i in 1:nstock){
       # stock[[i]] <- get_mortality(stock = stock[[i]]) # KILLS FISH
       # stock[[i]] <- get_indexData(stock = stock[[i]]) # GENERATES INDEX
        
      # WE'LL ADD IN THE ERROR WITH get_error_idx AND get_error_paa 
        
      #} #End killing fish loop

      # Store results- AM I SAVING THE RIGHT THING NOW? CHECK THESE FUNCTIONS
        # we save after mortality and new index generated but that would be different in this case
      
        #  for(i in 1:nstock){
        # if (y == nyear){
        #   stock[[i]] <- get_TermrelError(stock = stock[[i]])
        # }
        # 
        # if(y>=fmyearIdx){
        #   stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
        # }
        #  }
      
        # what does this do?
      end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)


        if(showProgBar==TRUE){
          setTxtProgressBar(iterpb, yearitercounter)
        }
      
      # assess_results needs the 4 extra rows (for piscivores, benthivores, planktivores, ecosystem??)
      # for now the assess_results just puts a fixed bmsy msy and fmsy
      source('processes/get_assess_results.R')
      assess_results <- get_assess_results(stock)
      
      source("functions/hydra/mp_functions.R")
      mp_results <- do_ebfm_mp(settings, assess_results, input)
      mp_results$out_table %>%
        as_tibble()
      
      # #the catch advice, to be passed to get_f_from_advice()
      # mp_results$out_table$advice
      # 
      source("functions/hydra/get_f_from_advice.R")
      
      # biomass for the F calculation, replace with something sensible
      f_calc_biomass <- dplyr::filter(as.data.frame(hydraData$predBiomass),year==max(year), survey==1) %>% 
        arrange(species) %>% select(predbiomass) %>% t() %>% as.numeric()
      #calculate new F
      F_full_new <- get_f_from_advice(mp_results$out_table$advice,
                                      f_calc_biomass, 
                                      input$q, 
                                      input$complex, 
                                      input$docomplex)
      
      
      # Set the new values for the next iteration of MSE
      # F_full is based on the recommended management model output
      # rec_devs are generated using the sigma value from the original hydra data
      # bs_temp is just the average bs_temp from the original data
      rec_devs_new <- rnorm(hydraData$Nspecies,0,sd=exp(hydraData$ln_recsigma))
      bs_temp_new <-9.643207
      
      # Update the growing list of new data
      bs_temp <- c(bs_temp,bs_temp_new)
      rec_devs <- c(rec_devs,rec_devs_new)
      F_full <- c(F_full,F_full_new)
      newdata <- list(bs_temp=bs_temp,F_full=F_full,rec_devs=rec_devs)
      
    }} #End of year loop 
  } #End of mproc loop
  
  # Save the output from this finished MSE:
  # Output the real biomass from the operating model
  OM_Biomass[[r]] <- hydraData$biomass
  # Output the real catch ("predcatch") and observed catch ("obscatch") from the operating model, removing unnecessary columns to save space
  OM_Catch[[r]] <- as.data.frame(hydraData$CN)[,-c(5,6,8,9)]
} #End rep loop

top_loop_end<-Sys.time()
big_loop<-top_loop_end-top_loop_start
big_loop

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
