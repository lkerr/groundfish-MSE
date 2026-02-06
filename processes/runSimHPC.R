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
  
  manage_counter<-0
  
  # Initialize stocks and determine burn-in F
  for(i in 1:nstock){
    stock[[i]] <- get_popInit(stock[[i]])
  }
  
  # Get historic assessment info if there is any
  for (i in 1:nstock){
    assess_vals <- get_HistAssess(stock = stock[[i]])
  }
  
  #Loop among years
  for(y in fyear:nyear){
    #Update poulation dynamics
    for(i in 1:nstock){
      stock[[i]] <- get_J1Updates(stock = stock[[i]],y=y,assess_vals=assess_vals)
    }
    
    yearitercounter<-yearitercounter+1
    
    begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
    
    # if historical period is over...
    if(y >= fmyearIdx){
      manage_counter<-manage_counter+1 
      
      #Get management advice
      for(i in 1:nstock){
        stock[[i]] <- get_advice(stock = stock[[i]],y=y,r=r)
      }
      
      #Apply implementation error if any
      for(i in 1:nstock){
        stock[[i]] <- get_implementationF(type = 'adviceWithError',
                                          stock = stock[[i]],y=y)
      } 
      
      #Calculate terminal relative error and fill in output for the year
      for(i in 1:nstock){
        if (y == nyear){
          stock[[i]] <- get_TermrelError(stock = stock[[i]],y=y)
        }
        stock[[i]] <- get_fillRepArrays(stock = stock[[i]],r=r,y=y)
      }
      
    }
    
    #Apply fishing mortality and get survey index 
    for(i in 1:nstock){
      stock[[i]] <- get_mortality(stock = stock[[i]],y=y)
      stock[[i]] <- get_indexData(stock = stock[[i]],y=y)
    } 
    
    end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)
    
    if(showProgBar==TRUE){
      setTxtProgressBar(iterpb, yearitercounter)
    }
  }
  #End of year loop
  
  top_loop_end<-Sys.time()
  
  td <- as.character(Sys.time())
  td2 <- gsub(':', '', td)
  td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')
  
  saveRDS(begin_rng_holder, file.path(econ_results_location,  paste0("begin_rng_",td2, ".Rds")), compress=FALSE)
  saveRDS(end_rng_holder, file.path(econ_results_location,  paste0("end_rng_",td2, ".Rds")), compress=FALSE)
  
  #Create figures
  for(i in 1:nstock){
    pth <- paste0('results/fig/', sapply(stock, '[[', 'stockName')[i])
    dir.create(pth, showWarnings = FALSE)
  }
  
  #### save results ####
  omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
  names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
  save(omvalGlobal, file=paste0('results/sim/omvalGlobal', td2, '.Rdata'))
  
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
