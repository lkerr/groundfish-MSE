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

#added pre-processing code here for validation and counterfatual scenarios 


#### Set up environment ####
rm(list=ls())

# the mproc file location is defined in  'modelParameters/set_om_parameters_global.R' and loaded by 'processes/generateMP.R'
# If you want to change it, you'll have to define new versions of these two files. Alternatveily, pass through a different file name and overwrite it later

# Which management procedures csv do you want to read:
#mprocfile<-"mproc.csv"
#mprocfile<-"mprocTest.csv"
mproc_manual<-"mprocEcon_validate.csv"
#mproc_manual<-"mprocEcon_counterfactual_closemult.csv"
#mproc_manual<-"mprocEcon_counterfactual_single.csv"

#runSetup.R loads things and sets them up. This is used by the integrated simulation, so be careful making changes with it. Instead, overwrite them using the setupEcon_extra.R file.
source('processes/runSetup_Econonly.R')




#the base runSetup.R runs source('processes/genBaselineACLs.R') to set up ACLs in the data.table econ_baseline.
# rather than change that file, we'll just overwrite with the econ-only version in the next step.

source('processes/genBaselineACLs_Econonly.R')
#Want to set the sector fishing to be 'unconstrained'?  Uncomment these two lines to set an ACL of 1M mt.
#econ_baseline$sectorACL_mt <- 1e6
#econ_baseline$totalACL_mt<-1e6

# if on local machine (i.e., not hpcc) must compile the tmb code
# (HPCC runs have a separate cal  l to compile this code). Keep out of
# runSetup.R because it is really a separate process on the HPCC.
if(runClass != 'HPCC'){
  source('processes/runPre.R', local=ifelse(exists('plotFlag'), TRUE, FALSE))
}



top_loop_start<-Sys.time()



####################These are temporary changes for testing ####################
#nrep<-2

mproc_bak<-mproc
#mproc<-mproc_bak[2:5,] #selects validation of four models

#mproc<-mproc_bak[17:20,] #selects "validation single"  
write.csv(mproc,file=file.path(ResultDirectory,"simulated_mproc.csv"))

# yrs contains the calendar years, the calendar year corresponding to y is yrs[y].  we want to go 'indexwise' through the year loop.
# I want to start the economic model at fmyear=2010 and temporarily end it in 2011
start_sim<-2010
end_sim<-2015

fyear<-which(yrs == start_sim)
nyear<-which(yrs == end_sim)

####################End Temporary changes for testing ####################
    

#set the rng state based on system time.  Store the random state.  

#set the rng state based on system time.  Store the random state.  
# if we use a plain old date (seconds since Jan 1, 1970), the number is actually too large, but we can just rebase to seconds since Jan 1, 2018.

start<-Sys.time()-as.POSIXct("2018-01-01 00:00:00",tz="","%Y-%m-%d %H:%M:%S")
start<-as.double(start)*100
set.seed(start)

oldseed_ALL <- .Random.seed
showProgBar<-TRUE    

####################End Parameter and storage Setup ####################
  #This depends on mproc, fyear, and nyear. So it should be run *after* it is reset. I could be put in the runSetup.R script. But since I'm  adjusting fyear and nyear temporarily, I need it here (for now).
    
source('processes/setupYearIndexing_Econ.R')

#### Top rep Loop ####
#for(r in 1:nrep){
for(r in 68:nrep){
  
    oldseed_mproc <- .Random.seed
    
  #### Top MP loop ####
    #now testing to see if this runs

    for(m in 1:nrow(mproc)){
      model = mproc$EconData[m]
      
      
      tchars<-nchar(model)
      modelno<-substr(model,tchars,tchars)

      manage_counter<-0
      
       #Restore the rng state.  Depending on whether you use oldseed1 or oldseed2, you'll get different behavior.  oldseed_ALL will force all the replicates to start from the same RNG state.  oldseed_mproc will force all the management procedures to have the same RNG state.  You probably want oldseed_mproc 
       #.Random.seed<-oldseed_ALL
       .Random.seed<-oldseed_mproc
       
        #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached, which sets of coefficients to use, and which prices to use
        if(mproc$ImplementationClass[m]=="Economic"){
         source('processes/setupEconType.R')
        }

    #### Top year loop ####
    for(y in fyear:nyear){
      
      source('processes/withinYearAdmin.R')
        if(y>=fmyearIdx){
            manage_counter<-manage_counter+1 #this only gets incremented when y>=fmyearIdx
          }
      
      #Construct the year-replicate index and use those to look up their values from random_sim_draw. This is currently unused.
          begin_rng_holder[[yearitercounter]]<- c(r,model,y,yrs[y],.Random.seed)     
          
  
        if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model
         
          # ---- Run the economic model here ----
          source('processes/loadEcon2.R')
          
          # subset just the current year of regulations
          econ_baseline_yearly<-econ_baseline[gffishingyear==yrs[y]]
          bio_params_for_econ <- get_bio_for_econ_only(stock,econ_baseline_yearly)

              source('processes/runEcon_moduleonly.R')
              end_rng_holder[[yearitercounter]]<-c(r,model,y,yrs[y],.Random.seed)    

            } #End Run Economic model if statement.
          
           
          #Save economic results once in a while to a csv file. 
        if(mproc$ImplementationClass[m]=="Economic" & (chunk_flag==0 | yearitercounter==max_yiter)) {

            revenue_holder<-rbindlist(revenue_holder) 
            fishery_output_holder<-rbindlist(fishery_output_holder) 
            fishery_prhat_holder<-rbindlist(fishery_prhat_holder,use.names=TRUE,fill=TRUE) 
            fishery_prhat_holder[is.na(fishery_prhat_holder)]<-0
            
            
            tda <- as.character(Sys.time())
            tda <- gsub(':', '', tda)
            tda<-gsub(' ', '_', tda)
            tda2 <- paste0(tda,"_", round(runif(1, 0, 10000)))
            write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",tda2, ".csv")), sep=",", row.names=FALSE)
            write.table(fishery_output_holder, file.path(econ_results_location, paste0("econ_stock_status_",tda2, ".csv")), sep=",", row.names=FALSE)
            write.table(fishery_prhat_holder, file.path(econ_results_location, paste0("prhat_",tda2, ".csv")), sep=",", row.names=FALSE)
            
            fishery_prhat_holder<-list()
            fishery_output_holder<-list()
            revenue_holder<-list()
            } #End save economic results if statement
          
        #Show progress bar  
          if(showProgBar==TRUE){
            setTxtProgressBar(iterpb, yearitercounter)
          }
          
      } #End of year loop
       #stopImplicitCluster()
       
       # Clean up mprocs 
        if(mproc$ImplementationClass[m]=="Economic"){
         source('processes/Econ_mproc_reset.R')
        }
       
        } #End mproc loop 
    
      } #End rep loop
      
    top_loop_end<-Sys.time()
    big_loop<-top_loop_end-top_loop_start
      # Output run time / date information and OM inputs. The random number is
  # just ensuring that no simulations will be overwritten because the hpcc
  # might finish some in the same second. td is used for uniquely naming the
  # output file as well as for listing in the output results.
  td <- as.character(Sys.time())
  td2 <- gsub(':', '', td)
  td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')
  
    
    saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
    saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)
    
    
     big_loop
     
  print(unique(warnings()))
  
  cat('\n ---- Successfully Completed ----\n')
