library(tibble)
library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(tidyverse)

#### Set up environment ####

rm(list=ls())
source('processes/runSetup.R')

# fyear=1
# nyear=5
# nrep = 5

# if on local machine (i.e., not hpcc) must compile the tmb code
# (HPCC runs have a separate call to compile this code). Keep out of
# runSetup.R because it is really a separate process on the HPCC.
if(runClass != 'HPCC'){
  source('processes/runPre.R', local=ifelse(exists('plotFlag'), TRUE, FALSE))
}

settings <- list(
  showTimeSeries = "No",
  useCeiling = "Yes",
  assessType = "stock complex",
  targetF = 0.75,
  floorB = 0.5,
  floorOption = "min status",
  bramp = 0.5,
  blim = 0.1,
  fmin = 0.01,
  floorYrs = 1:40)

#set up some dummy data
#input <- get_om_pars()
input <- NULL
input$Nsp = 10
#om_long <- run_om(input)

feeding_complexes <- tibble(isp = 1:10,
                            complex = c(1, 3, 3, 1, 2, 1, 1, 2, 1, 2))
gear_complexes <- tibble(isp = 1:10,
                         complex = c(1, 3, 3, 1, 1, 3, 1, 2, 1, 2))

input$complex = feeding_complexes$complex


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


# source('processes/setupYearIndexing.R')

top_loop_start<-Sys.time()

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
    newdata <- list(bs_temp=bs_temp,F_full=F_full)
    
    # For testing purposes
    # bs_temp <- c(9.1)
    # F_full <- rep(0.1,10)
    # newdata <- list(bs_temp=bs_temp,F_full=F_full)
    # End section for testing purposes
    
    source('functions/hydra/get_hydra.R')
    # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
    hydraData<- get_hydra(oldseed_mproc[r],newdata)
    
    # Adds observation error to the original data
    hydraData_init_index <- exp(rnorm(nrow(hydraData$predBiomass),log(hydraData$predBiomass[,'predbiomass'],base=exp(1)),hydraData$predBiomass[,'cv']))
    hydraData_init_catch <- exp(rnorm(nrow(hydraData$predCatch),log(hydraData$predCatch[,'predcatch'],base=exp(1)),hydraData$predCatch[,'cv']))
    hydraData_growing_index <- cbind(hydraData$predBiomass,obsbiomass=hydraData_init_index)
    hydraData_growing_catch <- cbind(hydraData$predCatch,obscatch=hydraData_init_catch)
    
    #### Top year loop ####
    for(y in fyear:nyear){
      # source('processes/withinYearAdmin.R')
      source("functions/hydra/mp_functions.R")
      
      # begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed) # what exactly is this doing? 
      # 
      # if(y >=fmyearIdx){
      # manage_counter<-manage_counter+1 #keeps track of management year
      # 
      # PULL IN -PREDICTED VALUES- FROM HYDRA DATA
      
      source('functions/hydra/get_hydra.R')
      # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
      hydraData<- get_hydra(oldseed_mproc[r],newdata)
      
      # Add observation noise but only to the newest year of data, the updates the growing list
      # EMILY: TURN THIS INTO A FUNCTION
      if(length(newdata$bs_temp)>0)
      {
        hydraData_new_index.df <- dplyr::filter(as.data.frame(hydraData$predBiomass),year==max(year))
        hydraData_new_catch.df <- dplyr::filter(as.data.frame(hydraData$predCatch),year==max(year))
        
        hydraData_new_index <- exp(rnorm(nrow(hydraData_new_index.df),log(hydraData_new_index.df[,'predbiomass'],base=exp(1)),hydraData_new_index.df[,'cv']))
        hydraData_new_catch <- exp(rnorm(nrow(hydraData_new_catch.df),log(hydraData_new_catch.df[,'predcatch'],base=exp(1)),hydraData_new_catch.df[,'cv']))
        hydraData_new_index.df <- cbind(hydraData_new_index.df,obsbiomass=hydraData_new_index)
        hydraData_new_catch.df <- cbind(hydraData_new_catch.df,obscatch=hydraData_new_catch)
        
        hydraData_growing_index <- rbind(hydraData_growing_index,hydraData_new_index.df)
        hydraData_growing_catch <- rbind(hydraData_growing_catch,hydraData_new_catch.df)
      }
      
      
      #Turn the data into tibbles to be read into the next thing
      index <- dplyr::filter(as.data.frame(hydraData_growing_index),survey==1)
      index <- data.frame(t=index$year,type=rep("biomass",nrow(index)),isp=index$species,value=index$obsbiomass)
      index <- as.tibble(index) %>% left_join(feeding_complexes)
      
      catch <- as.data.frame(hydraData_growing_catch)
      catch <- data.frame(t=catch$year,type=rep("catch",nrow(catch)),isp=catch$species,value=catch$obscatch)
      catch <- as.tibble(catch) %>% left_join(feeding_complexes)
      
      om_long <- bind_rows(index, catch)
      
      # NOT SURE ABOUT ANYTHING FROM HERE ON. BUT IT SHOULD:
      # -RUN ASSESSMENT
      # -GENERATE RESULTS FROM MP
      # -CREATE ADVICE (mp_results$out_table_advice)
      # -GRAB 10 NEW VALUES OF F_full_new FROM THE ADVICE
      # 
      # assess_results <- run_pseudo_assessments(om_long) 
      # #this currently generates data from the predictions, we would want to change so doesn't create new survey/catch time series each application
      # 
      # #call the MP
      # mp_results <- do_ebfm_mp(settings, assess_results, input)
      # mp_results$out_table %>% 
      #   as_tibble()
      # 
      # #the catch advice, to be passed to get_f_from_advice()
      # mp_results$out_table$advice
      # 
      # source("functions/hydra/get_f_from_advice")
      # F_full_new <- get_f_from_advice(mp_results$out_table$advice)
       
      #  # CONVERT TO AGES AND WRANGLE INTO CORRECT FORMAT
      #  # This function also has option to add additional observation noise, but
      #  # that is currently commented out
      #  for (i in 1:nstock) {
      #   stock[[i]] <- get_lengthConvert(stock=stock[[i]], hydraData)
      #  }
      #  
      #    
      # #### RUN MP ####
      #   for(i in 1:nstock){
      #     stock[[i]] <- get_advice(stock = stock[[i]]) # RUNS MP
      #   }
      #   
      # #### ADD IMPLEMENTATION ERROR ####
      #     for(i in 1:nstock){
      #       stock[[i]] <- get_implementationF(type = 'adviceWithError',
      #                                         stock = stock[[i]])
      #     } 
      # } # end of fishery management has started clause
      # 
      # # KILL FISH AND MAKE NEW CATCH AND INDEX FOR HYDRA HERE?
      # # IS GENERATING NEW CATCH AND INDEX DATA GOING TO BE DEPENDENT ON FISH INTERACTIONS?
      #   
      # for(i in 1:nstock){
      #  # stock[[i]] <- get_mortality(stock = stock[[i]]) # KILLS FISH
      #  # stock[[i]] <- get_indexData(stock = stock[[i]]) # GENERATES INDEX
      #   
      # # WE'LL ADD IN THE ERROR WITH get_error_idx AND get_error_paa 
      #   
      # } #End killing fish loop
      # 
      # # Store results- AM I SAVING THE RIGHT THING NOW? CHECK THESE FUNCTIONS
      #   # we save after mortality and new index generated but that would be different in this case
      # 
      #    for(i in 1:nstock){
      #   if (y == nyear){
      #     stock[[i]] <- get_TermrelError(stock = stock[[i]])
      #   }
      #   
      #   if(y>=fmyearIdx){
      #     stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
      #   }
      #    }
      # 
      #   # what does this do?
      # end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
      # 
      # 
      #   if(showProgBar==TRUE){
      #     setTxtProgressBar(iterpb, yearitercounter)
      #   }
         
      #### SEND F TO HYDRA HERE? RIGHT BEFORE END OF YEAR LOOP ####
      # you will need to pull stock[[i]]$F_full[y]
      
      # Here is where new bs_temp and F_full get added for the next hydra loop
      # bs_temp just adds the average temperature from time series each year, can change to pull randomly
      bs_temp <- c(bs_temp,9.643207)
      # F_full reads in as Year: Fleet 1 Fleet 2, Next year: Fleet 1 Fleet 2
      # F devs can only take one value for each fleet for each year...
      # F_full <- c(F_full,stock[[i]]$F_full[y])
      F_full_new <- rep(0.1,10)
      F_full <- c(F_full,F_full_new)
      newdata <- list(bs_temp=bs_temp,F_full=F_full)
      
    } #End of year loop 
  } #End of mproc loop

  #SAVE THE RESULTS FROM THE ITERATION HERE IN LIST
  #SOMETHING LIKE: N_results <- c(hydraData$EstNsize)
  
} #End rep loop
hydraData$EstNsize

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
