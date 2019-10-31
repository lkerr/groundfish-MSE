    ## This is a "small" version of the runSim.R file that is designed to run just the Economic simulations (POSTasPOST for validation or POSTasPRE as a counterfactual)
    
   # in the mproc.txt file, you'll want to adjust the last few columns to run different scenarios.
      # set the EconData column to be the "stub" of the data you want to read in
      #  EconType=Multi --> a closure in a stockarea closes everything in that stockarea (no landings of GB Cod if GB haddock is closed)
      #  EconType=Single --> a closure in a stockarea does not close everything in that stockarea ( landings of GB Cod allowed if GB haddock is closed) 
      #  CatchZero ==TRUE --> no catch of GB Cod if GB cod is closed
      #   CatchZero ==FALSE --> catch of GB Cod happens even if GB cod is closed (but all catch would be discarded).
      # LandZero is unused.


# NEEDS: 
  # check/verify that closing fisheries for jointness is coded properly.
  # 

#### Set up environment ####
rm(list=ls())
    
    #runSetup.R loads things and sets them up. This is used by the integrated simulation, so be careful making changes with it. Instead, overwrite them using the setupEcon_extra.R file.
source('processes/runSetup.R')
    



top_loop_start<-Sys.time()



####################These are temporary changes for testing ####################
econ_timer<-0
mproc_bak<-mproc
mproc<-mproc_bak[2:4,]
    ####################End Temporary changes for testing ####################
    
    
    ####################BEGIN Parameter and storage Setup ####################
    #dont change these
    yearcounter<-0
    #how many years before writing out the results to csv? 6 corresponds to 1 simulation
    chunksize<-6
    
    # yrs contains the calendar years.  we want to go 'indexwise' through the year loop.
    # calyear is yrs[y]
    # I want to start the economic model at fmyear=2010 and temporarily end it in 2011
    fyear<-which(yrs == fmyear)
    nyear<-fyear+1

    
    
    #set the rng state.  Store the random state.  
    set.seed(rnorm(1))
    oldseed_ALL <- .Random.seed
    
    revenue_holder<-list()
    #these two lists will hold a vectors that concatenates (r, m, y, calyear, .Random.seed). They should be r*m*y in length.
    begin_rng_holder<-list()
    end_rng_holder<-list()
    
    #dont change these
    ####################End Parameter and storage Setup ####################
    
    
    
    
     # Set up a small table that is useful for variablity across years in the economic model.
     eyears<-nyear-fyear+1
     random_sim_draw <-as.data.table(cbind(rep(1:nrep,each=eyears), rep(fyear:nyear,nrep))) 
     colnames(random_sim_draw)<-c("econ_replicate","sim_year_idx")
     random_sim_draw[, econ_year:=yrs[sim_year_idx]]
     random_sim_draw[, econ_year_idx:=econ_year-fmyear+1]
     
     max_eyear<-nrow(random_sim_draw)
     eyear_idx<-0

     maxyc<-nrep*nrow(mproc)*(nyear-fyear+1)
         

  #### Top rep Loop ####
for(r in 1:nrep){
    oldseed_mproc <- .Random.seed
    
  #### Top MP loop ####
    #now testing to see if this runs
    for(m in 1:nrow(mproc)){
    
       eyear_idx<-0
      
       #Restore the rng state.  Depending on whether you use oldseed1 or oldseed2, you'll get different behavior.  oldseed_ALL will force all the replicates to start from the same RNG state.  oldseed_mproc will force all the management procedures to have the same RNG state.  You probably want oldseed_mproc 
       #.Random.seed<-oldseed_ALL
       .Random.seed<-oldseed_mproc
       
        #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached, which sets of coefficients to use, and which prices to use
        if(mproc$ImplementationClass[m]=="Economic"){
         source('processes/setupEconType.R')
        }
        #### Top year loop ####
        for(y in fyear:nyear){
          eyear_idx<-eyear_idx+1
          yearcounter<-yearcounter+1
          calyear<-yrs[y]
          begin_rng_holder[[yearcounter]]<- c(r,m,y,calyear,.Random.seed)     
          econ_year_draw<-random_sim_draw[eyear_idx,econ_year]
          econ_idx_draw<-random_sim_draw[eyear_idx,econ_year_idx]
          
          #Construct the year-replicate index and use those to look up their values from random_sim_draw. This is currently unused.

          chunk_flag<-yearcounter %% chunksize
  
        if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model
         
          # ---- Run the economic model here ----
          source('processes/loadEcon2.R')
       
          
          bio_params_for_econ <- get_bio_for_econ(stock,econ_baseline)

          start_time<-proc.time() 
              source('processes/runEcon_moduleonly.R')
              econ_timer<-econ_timer+proc.time()[3]-start_time[3]
              end_rng_holder[[yearcounter]]<-c(r,m,y,calyear,.Random.seed)    
              
            } #End Run Economic model if statement.
          
           
          #Save economic results once in a while to a csv file. 
        if(mproc$ImplementationClass[m]=="Economic" & (chunk_flag==0 | yearcounter==maxyc)) {
            revenue_holder<-rbindlist(revenue_holder) 
            tda <- as.character(Sys.time())
            tda <- gsub(':', '', tda)
            tda<-gsub(' ', '_', tda)
            tda2 <- paste0(tda,"_", round(runif(1, 0, 10000)))
            write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",tda2, ".csv")), sep=",", row.names=FALSE)
            revenue_holder<-list()
            } #End save economic results if statement
           
          } #End year loop
  
        } #End mproc loop 
      } #End rep loop
      
    top_loop_end<-Sys.time()
    big_loop<-top_loop_end-top_loop_start
    
    td <- as.character(Sys.time())
    td <- gsub(':', '', td)
    td<-gsub(' ', '_', td)
    td2 <- paste0(td,"_", round(runif(1, 0, 10000)))
    
    
    saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
    saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)
    
    
     econ_timer
     big_loop
     
      
      cat('\n ---- Successfully Completed ----\n')
