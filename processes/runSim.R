

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
       F_devs <- c()
       newdata <- list(bs_temp=bs_temp,F_devs=F_devs)
    #### Top year loop ####
    for(y in fyear:nyear){
      source('processes/withinYearAdmin.R')
      begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed) # what exactly is this doing? 
      
      if(y >=fmyearIdx){
      manage_counter<-manage_counter+1 #keeps track of management year
      
      # PULL IN -PREDICTED VALUES- FROM HYDRA DATA
      source('functions/hydra/get_hydra.R')
      # get_hydra will also incorporate a growing data frame called newdata that gets larger as the loop progresses
      hydraData<- get_hydra(oldseed_mproc[r],newdata)
       
       
       # CONVERT TO AGES AND WRANGLE INTO CORRECT FORMAT
       # This function also has option to add additional observation noise, but
       # that is currently commented out
       for (i in 1:nstock) {
        stock[[i]] <- get_lengthConvert(stock=stock[[i]], hydraData)
       }
       
         
      #### RUN MP ####
        for(i in 1:nstock){
          stock[[i]] <- get_advice(stock = stock[[i]]) # RUNS MP
        }
        
      #### ADD IMPLEMENTATION ERROR ####
          for(i in 1:nstock){
            stock[[i]] <- get_implementationF(type = 'adviceWithError',
                                              stock = stock[[i]])
          } 
      } # end of fishery management has started clause

      # KILL FISH AND MAKE NEW CATCH AND INDEX FOR HYDRA HERE?
      # IS GENERATING NEW CATCH AND INDEX DATA GOING TO BE DEPENDENT ON FISH INTERACTIONS?
        
      for(i in 1:nstock){
       # stock[[i]] <- get_mortality(stock = stock[[i]]) # KILLS FISH
       # stock[[i]] <- get_indexData(stock = stock[[i]]) # GENERATES INDEX
        
      # WE'LL ADD IN THE ERROR WITH get_error_idx AND get_error_paa 
        
      } #End killing fish loop
      
      # After killing fish loop, make a list called newdata that will be added to hydra in next iteration
      # newdata <-list()
      # newdata$bs_temp 
      # newdata$obs_survey_biomass 
      # newdata$obs_survey_size 
      # newdata$obs_catch_biomass 
      # newdata$obs_catch_size 
      # newdata$obs_diet_prop 
      # newdata$recruitment_devs 
      # newdata$F_devs 

      # Store results- AM I SAVING THE RIGHT THING NOW? CHECK THESE FUNCTIONS
        # we save after mortality and new index generated but that would be different in this case
      
         for(i in 1:nstock){
        if (y == nyear){
          stock[[i]] <- get_TermrelError(stock = stock[[i]])
        }
        
        if(y>=fmyearIdx){
          stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
        }
         }
      
        # what does this do?
      end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)


        if(showProgBar==TRUE){
          setTxtProgressBar(iterpb, yearitercounter)
        }
         
      #### SEND F TO HYDRA HERE? RIGHT BEFORE END OF YEAR LOOP ####
      # you will need to pull stock[[i]]$F_full[y]
      
    } #End of year loop 
  } #End of mproc loop
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
