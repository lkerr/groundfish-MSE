## This is a "small" version of the runSim.R file that is designed to run the Economic Counterfactual simulation (post-as-pre).

# We comment out all the biological aspects of the model. 


#### Set up environment ####

# empty the environment
rm(list=ls())
gc()

source('processes/runSetup.R')
source('processes/setupEcon_extra.R')
if(!require(readstata13)) {  
  install.packages("readstata13")
  require(readstata13)}
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


####################End Temporary changes for testing ####################
replicates<-1
firstrepno<-1

set.seed(53)

# Need to load in the previous RNG state?
# full.pathRNG<-file.path(proj_dir, econ_results_location)
# rng_pattern<-"end_rng.*Rds$"
# source('processes/loadsetRNG.R')

#how many years before writing out the results to csv? 6 corresponds to 1 simulation
chunksize<-6


############################################################
#dont change these
lastrepno<-replicates+firstrepno-1
fyear<-2010
nyear<-2015
fmyearIdx<-fyear
# Set up a small table that is useful for variablity across years in the economic model.
eyears<-nyear-fyear+1
random_sim_draw <-as.data.table(cbind(rep(firstrepno:lastrepno,each=eyears), rep(fyear:nyear,replicates)))
colnames(random_sim_draw)<-c("econ_replicate","econ_year")
random_sim_draw[, econ_year_idx:=econ_year-fyear+1]
eyear_idx<-0
max_eyear<-nrow(random_sim_draw)
############################################################

revenue_holder<-list()
begin_rng_holder<-list()
end_rng_holder<-list()
#### Top rep Loop ####



# for testing purposes
nyear<-2010

for(r in firstrepno:lastrepno){

  #### Top MP loop ####
  for(m in 1:nrow(mproc)){

    #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached.
    econtype<-mproc[m,]
    myvars<-c("LandZero","CatchZero","EconType","EconData")
    econtype<-econtype[myvars]
    econ_data_stub<-econtype["EconData"]
    if (econ_data_stub=='validation'){
    multiplier_loc<-"sim_multipliers_post.Rds"
      # Read in Economic Production Data. These are relatively lists of data.tables. So it makes sense to read in once and then list-subset [[]] later on.
      
    } else if (econ_data_stub=='counterfactual'){
    multiplier_loc<-"sim_multipliers_pre.Rds"
    output_price_loc<-"sim_prices_post.Rds"
    input_price_loc<-"sim_post_vessel_stock_prices.Rds"
    
    }
    else {
    multiplier_loc<-"sim_multipliers_post.Rds"
    output_price_loc<-"sim_prices_post.Rds"
    input_price_loc<-"sim_post_vessel_stock_prices.Rds"
    
    }
    multipliers<-readRDS(file.path(econdatapath,multiplier_loc))
    outputprices<-readRDS(file.path(econdatapath,output_price_loc))
    inputprices<-readRDS(file.path(econdatapath,input_price_loc))
    
    
    # Initialize stocks and determine burn-in F
    # for(i in 1:nstock){
    #   stock[[i]] <- get_popInit(stock[[i]])
    # }

    
    #### Top year loop ####
    for(y in fyear:nyear){
      
      #Construct the year-replicate index and use those to look up their values from random_sim_draw
      eyear_idx<-eyear_idx+1
      econ_year_draw<-random_sim_draw[[eyear_idx,2]]
      econ_idx_draw<-random_sim_draw[[eyear_idx,3]]
      
      begin_rngstate<-  .Random.seed 
      begin_rng_holder[[eyear_idx]]<-begin_rngstate    
      chunk_flag<-eyear_idx %% chunksize
            # 
      # for(i in 1:nstock){
      #   stock[[i]] <- get_J1Updates(stock = stock[[i]])
      # }
      

      # if burn-in period is over...
      if(y >= fmyearIdx){

        # for(i in 1:nstock){
        #   stock[[i]] <- get_advice(stock = stock[[i]])
        #   stock[[i]] <- get_relError(stock = stock[[i]])
        # }
        
        if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model
          
          # for(i in 1:nstock){
          #   # Specific "survey" meant to track the population on Jan1
          #   # for use in the economic submodel. timeI=0 implies Jan1.
          #   stock[[i]]<- within(stock[[i]], {
          #     IJ1[y,] <- get_survey(F_full=0, M=0, N=J1N[y,], slxC[y,], 
          #                       slxI=selI, timeI=0, qI=qI)
          #   })
          # }

          
          # ---- Run the economic model here ----
          source('processes/loadEcon2.R')
          bio_params_for_econ <- get_bio_for_econ(stock,econ_baseline)

          start_time<-proc.time() 
          source('processes/runEcon_moduleonly.R')
          econ_timer<-econ_timer+proc.time()[3]-start_time[3]
          
          end_rngstate<-  .Random.seed 
          end_rng_holder[[eyear_idx]]<-end_rngstate    
          
        }
      }
        # else if(mproc$ImplementationClass[m] == "StandardFisheries"){
        #   
        #   for(i in 1:nstock){
        #     stock[[i]] <- get_implementationF(type = 'adviceWithError', 
        #                                       stock = stock[[i]])
        #   }
        #   
           #else{
            #Add a warning about invalid ImplementationClass
          #}
        
        # for(i in 1:nstock){
        #   stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
        # }
         
      #Save results once in a while to a csv file. 
      if (chunk_flag==0 | eyear_idx==max_eyear) {
        revenue_holder<-rbindlist(revenue_holder) 
        td <- as.character(Sys.time())
        td <- gsub(':', '', td)
        td<-gsub(' ', '_', td)
        td2 <- paste0(td,"_", round(runif(1, 0, 10000)))
        #save.dta13(revenue_holder, file.path(econ_results_location, paste0("econ_",td2, ".dta")))
        write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",td2, ".csv")), sep=",", row.names=FALSE)
        revenue_holder<-list()
        gc()
        }
       
      }

      # for(i in 1:nstock){
      #   stock[[i]] <- get_mortality(stock = stock[[i]])
      #   stock[[i]] <- get_indexData(stock = stock[[i]])
      # }
      # }
    }
  }
  
top_loop_end<-Sys.time()
big_loop<-top_loop_end-top_loop_start

saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)


 econ_timer
  big_loop
 

#   
# revenue_holder<-rbindlist(revenue_holder) 
# revenue_holder<-as.data.table(revenue_holder)
# setcolorder(revenue_holder, c("r","m","y", "doffy"))
  # Output run time / date information and OM inputs. The random number is
  # just ensuring that no simulations will be overwritten because the hpcc
  # might finish some in the same second. td is used for uniquely naming the
  # output file as well as for listing in the output results.
  # 
  # 
  # # create a results & sim directories
  # dir.create('results', showWarnings = FALSE)
  # dir.create('results/sim', showWarnings = FALSE)
  # dir.create('results/fig', showWarnings = FALSE)
  # for(i in 1:nstock){
  #   pth <- paste0('results/fig/', sapply(stock, '[[', 'stockName')[i])
  #   dir.create(pth, showWarnings = FALSE)
  # }
  # 
  # 
  # #### save results ####
  # omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
  # names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
  # save(omvalGlobal, file=paste0('results/sim/omvalGlobal', td2, '.Rdata'))
  # 
  # if(runClass != 'HPCC'){
  #   omparGlobal <- readLines('modelParameters/set_om_parameters_global.R')
  #   cat('\n\nSuccess.\n\n',
  #       'Completion at: ',
  #       td,
  #       file='results/runInfo.txt', sep='')
  #   cat('\n\n\n\n\n\n\n\n  ##### Global OM Parameters ##### \n\n',
  #       omparGlobal,
  #       file='results/runInfo.txt', sep='\n', append=TRUE)
  #   for(i in 1:nstock){
  #     cat('\n\n\n\n\n\n\n\n  ##### Stock OM Parameters ##### \n\n',
  #         readLines(fileList[i]), 
  #         file='results/runInfo.txt', sep='\n', append=TRUE)
  #   }
  # }
  # 
  # 
  # 
  # if(runClass != 'HPCC'){
  #   # Note that runPost.R re-sets the containers; results have already been
  #   # saved however.
  #   source('processes/runPost.R')
  # }
  # 
  # 
  # print(unique(warnings()))
  
  cat('\n ---- Successfully Completed ----\n')
