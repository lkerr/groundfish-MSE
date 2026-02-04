#### Set up environment ####
setwd('/home/mam006/Documents/mam006/groundfish-MSE')
nrep<-100 #Determine number of reps

#create a dataframe with each rep as a row for rslurm
pars<-as.data.frame(1:nrep)
colnames(pars)<-c('nrep')

#### Function to pass to HPC####
HPCfunsim<- function(nrep){
  
  #Set directory to get relevant parameters and code and set up simulation
  setwd('/home/mam006/Documents/mam006/groundfish-MSE')
  source('processes/runSetup.R')
  source('processes/setupYearIndexing.R')
  
  showProgBar<-TRUE
  
  #1 stock, 1 rep per simulation
  nstock<-1
  r<-1
  #set seed 
  set.seed(sample(1:100,1))
  
  #### MP loop ####
  for(m in 1:1){
    
    manage_counter<-0
    
    #Restore the rng state.  Depending on whether you use oldseed1 or oldseed2, you'll get different behavior.  oldseed_ALL will force all the replicates to start from the same RNG state.  oldseed_mproc will force all the management procedures to have the same RNG state.  You probably want oldseed_mproc
    #.Random.seed<-oldseed_ALL
    # .Random.seed<-oldseed_mproc
    
    #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached, which sets of coefficients to use, and which prices to use
    if(mproc$ImplementationClass[m]=="Economic"){
      
      source('processes/setupEconType.R')
    }
    # Initialize stocks and determine burn-in F
    
    for(i in 1:nstock){
      stock[[i]] <- get_popInit(stock[[i]])
    }
    #### get historic assessment info if there is any
    # if (histAssess == TRUE) {
    for (i in 1:nstock){
      assess_vals <- get_HistAssess(stock = stock[[i]])
    }
    # }
    #### Top year loop ####
    for(y in fyear:nyear){
      for(i in 1:nstock){
        stock[[i]] <- get_J1Updates(stock = stock[[i]],y=y,assess_vals=assess_vals)
      }
      
      yearitercounter<-yearitercounter+1
      
      chunk_flag<-yearitercounter %% savechunksize
      
      begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
      
      # if burn-in period is over...
      if(y >= fmyearIdx){
        manage_counter<-manage_counter+1 #this only gets incremented when y>=fmyearIdx
        
        for(i in 1:nstock){
          stock[[i]] <- get_advice(stock = stock[[i]],y=y,r=r)
          #stock[[i]] <- get_relError(stock = stock[[i]])
        }
        #Construct the year-replicate index and use those to look up their values from random_sim_draw. This is currently unused.
        
        if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model
          
          for(i in 1:nstock){
            # Specific "survey" meant to track the population on Jan1
            # for use in the economic submodel. timeI=0 implies Jan1.
            stock[[i]]<- within(stock[[i]], {
              IJ1[y,] <- get_survey(F_full=0, M=0, N=J1N[y,], slxC[y,],
                                    slxI=selI, timeI=0, qI=qI)
            })
          } # End survey loop
          
          
          # ---- Run the economic model here ----
          source('processes/loadEcon2.R')
          
          
          bio_params_for_econ <- get_bio_for_econ(stock,econ_baseline)
          
          source('processes/runEcon_module.R')
          
        }else if(mproc$ImplementationClass[m] == "StandardFisheries"){
          
          for(i in 1:nstock){
            stock[[i]] <- get_implementationF(type = 'adviceWithError',
                                              stock = stock[[i]],y=y)
          } # End implementation error in standard fisheries
          
        }else{
          #Add a warning about invalid ImplementationClass
        }
        
        for(i in 1:nstock){
          if (y == nyear){
            stock[[i]] <- get_TermrelError(stock = stock[[i]],y=y)
          }
          stock[[i]] <- get_fillRepArrays(stock = stock[[i]],r=r,y=y)
        }
        
      } #End of burn-in loop
      
      for(i in 1:nstock){
        stock[[i]] <- get_mortality(stock = stock[[i]],y=y)
        stock[[i]] <- get_indexData(stock = stock[[i]],y=y)
      } #End killing fish loop
      
      
      end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
      
      if(showProgBar==TRUE){
        setTxtProgressBar(iterpb, yearitercounter)
      }
    }
    #End of year loop
  } #End of mproc loop
  
  
  #End rep loop
  
  cat('finished rep')
  
  top_loop_end<-Sys.time()
  
  #econ_timer
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
    pth <- paste0('results/fig/', sapply(stock, '[[', 'stockName')[i])
    dir.create(pth, showWarnings = FALSE)
  }
  
  #### save results ####
  omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
  names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
  save(omvalGlobal, file=paste0('results/sim/omvalGlobal', td2, '.Rdata'))
  
  cat('saved sims')
  
  print(unique(warnings()))
  
  cat('\n ---- Successfully Completed ----\n')
}

library(rslurm)
MSEsim_May9<-slurm_apply(HPCfunsim,pars,
                         jobname = "HPCfunsim_Nov17",
                         nodes = 160,
                         cpus_per_node = 1,
                         submit = FALSE,
                         slurm_options = list(time = "120:00:00", nodes = 1, account = "dfo_pfm", partition = "standard", export = "USER,LOGNAME,HOME,MAIL,PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", qos = "low", `ntasks-per-node` = 1, `mem-per-cpu` = "6400M",`mail-type` = "BEGIN,END,FAIL", `mail-user` = "mackenzie23mazur@gmail.com"),
                         pkgs = c("dplyr", "sdmTMB"),
                         rscript_path = "/fs/vnas_Hdfo/comda/mam006/Documents/mam006",
                         libPaths="/gpfs/fs7/dfo/hpcmc/pfm/mam006/rlib/4.3",
                         sh_template= "/fs/vnas_Hdfo/comda/mam006/Documents/mam006/template_sh.txt")
