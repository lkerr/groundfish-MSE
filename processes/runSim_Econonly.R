    ## This is a "small" version of the runSim.R file that is designed to run just the Economic simulations (POSTasPOST for validation or POSTasPRE as a counterfactual)
    
   # in the mproc.txt file, you'll want to adjust the last few columns to run different scenarios.
      # set the EconData column to be the "stub" of the data you want to read in
      #  EconType=Multi --> a closure in a stockarea closes everything in that stockarea (no landings of GB Cod if GB haddock is closed)
      #  EconType=Single --> a closure in a stockarea does not close everything in that stockarea ( landings of GB Cod allowed if GB haddock is closed) 
      #  CatchZero ==TRUE --> no catch of GB Cod if GB cod is closed
      #   CatchZero ==FALSE --> catch of GB Cod happens even if GB cod is closed (but all catch would be discarded).
      # LandZero is unused.

#### Set up environment ####
    rm(list=ls())
    gc()
    
    #runSetup.R loads things and sets them up. This is used by the integrated simulation, so be careful making changes with it. Instead, overwrite them using the setupEcon_extra.R file.
    source('processes/runSetup.R')
    
    #setupEcon_extra.R makes modfications for the "Econ_only" run.  
    
    source('processes/setupEcon_extra.R')
    if(!require(readstata13)) {  
      install.packages("readstata13")
      require(readstata13)}
    #set up directories.  Create directories.
    proj_dir<- "/home/mlee/Documents/projects/GroundfishCOCA/groundfish-MSE"
    
    dir.create('results', showWarnings = FALSE)
    dir.create('results/econ', showWarnings = FALSE)
    dir.create('results/econ/raw', showWarnings = FALSE)
    econ_results_location<-"results/econ/raw"
     
    
    top_loop_start<-Sys.time()
    ####################These are temporary changes for testing ####################
    econ_timer<-0
    mproc_bak<-mproc
    mproc<-mproc_bak[c(3,4),]
    #mproc<-mproc_bak[c(4),]
    firstrepno<-1
    ####################End Temporary changes for testing ####################
    
    
    ####################BEGIN Parameter and storage Setup ####################
    #dont change these
    
    replicates<-1
    #how many years before writing out the results to csv? 6 corresponds to 1 simulation
    chunksize<-6
    

    lastrepno<-replicates+firstrepno-1
    fyear<-2010
    nyear<-2015
    fmyearIdx<-2010
    #set the rng state.  Store the random state.  
    set.seed(3)
    oldseed1 <- .Random.seed
    
    revenue_holder<-list()
    begin_rng_holder<-list()
    end_rng_holder<-list()
    
    #dont change these
    ####################End Parameter and storage Setup ####################
    
    # Set up a small table that is useful for variablity across years in the economic model.
    eyears<-nyear-fyear+1
    random_sim_draw <-as.data.table(cbind(rep(firstrepno:lastrepno,each=eyears), rep(fyear:nyear,replicates))) 
    colnames(random_sim_draw)<-c("econ_replicate","econ_year")
    
    random_sim_draw[, econ_year_idx:=econ_year-fyear+1]
    max_eyear<-nrow(random_sim_draw)
    eyear_idx<-0
  
    # Need to load in the previous RNG state?
    # full.pathRNG<-file.path(proj_dir, econ_results_location)
    # rng_pattern<-"end_rng.*Rds$"
    # source('processes/loadsetRNG.R')
    
  #### Top rep Loop ####
  for(r in firstrepno:lastrepno){
    oldseed2 <- .Random.seed
    
  #### Top MP loop ####
    for(m in 1:nrow(mproc)){
      
       eyear_idx<-0
      
        #Restore the rng state.  Depending on whether you use oldseed1 or oldseed2, you'll get different behavior.  oldseed1 will force all the replicates to start from the same RNG state.  oldseed2 will force all the management procedures to have the same RNG state.  You probably want this. 
        #.Random.seed<-oldseed1
       .Random.seed<-oldseed2
        
        #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached.
        econtype<-mproc[m,]
        source('processes/setupEconType.R')
        
        #### Top year loop ####
        for(y in fyear:nyear){
          #Construct the year-replicate index and use those to look up their values from random_sim_draw
          eyear_idx<-eyear_idx+1
          econ_year_draw<-random_sim_draw[[eyear_idx,2]]
          econ_idx_draw<-random_sim_draw[[eyear_idx,3]]
          
          begin_rng_holder[[eyear_idx]]<- .Random.seed     
          chunk_flag<-eyear_idx %% chunksize
  
            if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model
         
             # ---- Run the economic model here ----
           
                source('processes/loadEcon2.R')
              bio_params_for_econ <- get_bio_for_econ(stock,econ_baseline)
      
              start_time<-proc.time() 
              source('processes/runEcon_moduleonly.R')
              econ_timer<-econ_timer+proc.time()[3]-start_time[3]
              end_rng_holder[[eyear_idx]]<-.Random.seed    
              
            }
          
           
          #Save results once in a while to a csv file. 
          if (chunk_flag==0 | eyear_idx==max_eyear) {
            revenue_holder<-rbindlist(revenue_holder) 
            td <- as.character(Sys.time())
            td <- gsub(':', '', td)
            td<-gsub(' ', '_', td)
            td2 <- paste0(td,"_", round(runif(1, 0, 10000)))
            write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",td2, ".csv")), sep=",", row.names=FALSE)
            revenue_holder<-list()
            gc()
            }
           
          }
  
        }
      }
      
    top_loop_end<-Sys.time()
    big_loop<-top_loop_end-top_loop_start
    
    saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
    saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)
    
    
     econ_timer
     big_loop
     
      
      cat('\n ---- Successfully Completed ----\n')
