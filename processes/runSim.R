

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

top_loop_start<-Sys.time()
econ_timer<-0
#set.seed(2)
#### Top rep Loop ####
for(r in 1:nrep){

  # Use the same random numbers for each of the management strategies
  # set.seed(NULL)
  # rsd <- rnorm()
  
  #### Top MP loop ####
  for(m in 1:nrow(mproc)){

    # set.seed(rsd)
    
    
    # Initialize stocks and determine burn-in F
    for(i in 1:nstock){
      stock[[i]] <- get_popInit(stock[[i]])
    }
    
    #### get historic assessment info if there is any
    if (histAssess == TRUE) {
      for (i in 1:nstock){
      assess_vals <- get_HistAssess(stock = stock[[i]])
      }
    }

    
    #### Top year loop ####
    for(y in fyear:nyear){
      for(i in 1:nstock){
        stock[[i]] <- get_J1Updates(stock = stock[[i]])
      }
    
      
      # option to overwrite calcualted values with historic assessment input values for each year #AEW 
      # just fishing mortality for now
      # if (histAssess == TRUE) {
      #   for(i in 1:nstock){
      #     if(y %in% assess_vals$assessdat$MSEyr){
      #     rep_assess <- get_AssessVals()
      #     stock[[i]]$F_full[y] <- rep_assess$fish_mort
      #     stock[[i]]$R[y] <- rep_assess$rec
      #  }
      # 
      # }
      # }
        
      
    
      # if burn-in period is over...
      if(y >= fmyearIdx){

        
        for(i in 1:nstock){
          stock[[i]] <- get_advice(stock = stock[[i]])
          #stock[[i]] <- get_relError(stock = stock[[i]])
        }
        
        if(mproc$ImplementationClass[m]=="Economic"){ #Run the economic model

          for(i in 1:nstock){
            # Specific "survey" meant to track the population on Jan1
            # for use in the economic submodel. timeI=0 implies Jan1.
            stock[[i]]<- within(stock[[i]], {
              IJ1[y,] <- get_survey(F_full=0, M=0, N=J1N[y,], slxC[y,], 
                                slxI=selI, timeI=0, qI=qI)
            })
          }

          
          # ---- Run the economic model here ----
          bio_params_for_econ <- get_bio_for_econ(stock,econ_baseline)

          start_time<-proc.time() 
          # progress(y,progress.bar=TRUE)
          source('scratch/econscratch/working_econ_module.R')
          econ_timer<-econ_timer+proc.time()[3]-start_time[3]
          
        }else if(mproc$ImplementationClass[m] == "StandardFisheries"){
          
          for(i in 1:nstock){
            stock[[i]] <- get_implementationF(type = 'adviceWithError', 
                                              stock = stock[[i]])
          }
          
          }else{
            #Add a warning about invalid ImplementationClass
          }
        
        for(i in 1:nstock){
          stock[[i]] <- get_relError(stock = stock[[i]])
          stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
        }
      
      
      # get catch in numbers using the Baranov catch equation from advised F    
      for (i in 1:nstock){
          stock[[i]] <- get_mortality(stock = stock[[i]], hotW = TRUE)
      }  
      
        for(i in 1:nstock){
          if(stock[[i]]$stockName == 'codGOM'){
            
            # Figure out the advised catch weight
            codCW <- with(stock$codGOM, CN_temp[y,] %*%  waa[y,])

            # add bias to catch weight
            codCW2 <- codCW + (codCW * stock$codGOM$C_mult)
            
            # Determine what the fishing mortality would have to be to get
            # that biased catch level (convert biased catch back to F).
            # Update codGOM fully selected fishing mortality to that value.
             stock$codGOM$F_full[y] <- get_PopesF(yield = c(codCW2),
                                                  naa = stock$codGOM$J1N[y,],
                                                  waa = stock$codGOM$waa[y,],
                                                  saa = stock$codGOM$slxC[y,],
                                                  M = stock$codGOM$M,
                                                  ra = c(8))
            
            
            # either way works;
            # stock$codGOM$F_full[y] <- get_F(x = c(codCW2), 
            #                                    Nv = stock$codGOM$J1N[y,], 
            #                                    slxCv = stock$codGOM$slxC[y,], 
            #                                    M = stock$codGOM$M, 
            #                                    waav = stock$codGOM$waa[y,])
            }    
        
        }  
        
        
      } #end management period
      
      for(i in 1:nstock){
        stock[[i]] <- get_mortality(stock = stock[[i]])
        stock[[i]] <- get_indexData(stock = stock[[i]])
      }
        
      } #end year loop

    } # end mproc loop
    
  } #end nrep loop
  
top_loop_end<-Sys.time()
big_loop<-top_loop_end-top_loop_start
big_loop
econ_timer

  
  
  # Output run time / date information and OM inputs. The random number is
  # just ensuring that no simulations will be overwritten because the hpcc
  # might finish some in the same second. td is used for uniquely naming the
  # output file as well as for listing in the output results.
  td <- as.character(Sys.time())
  td2 <- gsub(':', '', td)
  td2 <- paste(gsub(' ', '_', td2), round(runif(1, 0, 10000)), sep='_')
  
  
  # create a results & sim directories
  dir.create('results', showWarnings = FALSE)
  dir.create('results/sim', showWarnings = FALSE)
  dir.create('results/fig', showWarnings = FALSE)
  for(i in 1:nstock){
    pth <- paste0('results/fig/', sapply(stock, '[[', 'stockName')[i])
    dir.create(pth, showWarnings = FALSE)
  }
  
  
  #### save results ####
  omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
  names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
  save(omvalGlobal, file=paste0('results/sim/omvalGlobal', td2, '.Rdata'))
  
  if(runClass != 'HPCC'){
    omparGlobal <- readLines('modelParameters/set_om_parameters_global.R')
    cat('\n\nSuccess.\n\n',
        'Completion at: ',
        td,
        file='results/runInfo.txt', sep='')
    cat('\n\n\n\n\n\n\n\n  ##### Global OM Parameters ##### \n\n',
        omparGlobal,
        file='results/runInfo.txt', sep='\n', append=TRUE)
    for(i in 1:nstock){
      cat('\n\n\n\n\n\n\n\n  ##### Stock OM Parameters ##### \n\n',
          readLines(fileList[i]), 
          file='results/runInfo.txt', sep='\n', append=TRUE)
    }
  }
  
  
  
  if(runClass != 'HPCC'){
    # Note that runPost.R re-sets the containers; results have already been
    # saved however.
    source('processes/runPost.R')
  }
  
  
  print(unique(warnings()))
  
  cat('\n ---- Successfully Completed ----\n')
