#' @title Run MSE Simulations
#' @description Main function to run MSE simulations. Previously this function was sourced to run simulations, now input arguments must be provided to run.
#' 
#' @param runHPCC A boolean, if TRUE requires running the runPre.R script on HPCC, if FALSE set up results directory for local run. Default = TRUE. 
#' @param stockNames A string or vector of strings indicating what stocks to include in analysis. To add new stocks to the simulation provide newStockPar argument below, to use a mix of new and existing stocks provide both stockNames for existing and newStockPar for new stocks. 
#' Options for existing stocks include: 
#' \itemize{
#'   \item{"codGB"} 
#'   \item{"codGOM"} 
#'   \item{"haddockGB"} 
#'   \item{"pollock"}
#'   \item{"yellowtailflounderGB"}
#' } 
#' @param newStockPar A string or vector of strings indicating the file path(s) to new stock parameter files, no default but example file available in templates folder. ??? check that this folder accessible in R package, may need to provide link to templates folder on GitHub instead
#' @param mproc !!! A data object not name of .csv file, name of object, you need to read in .csv when setting up sim
#' @param simpleTemperature A boolean indicating whether smoothed (simple) temperature trend used for debugging purposes, default = FALSE.
#' @param histAssess A boolean, if TRUE overwrite calculated values with historic assessment input values for each year, default = TRUE.
#' @param nrep The number of times to repeat this analysis, default = 1.
#' @template global_fmyear
#' @template global_fyear
#' @param mxyear The maximum year predicted into the future, no default.
#' @param nburn Number of burn-in years, default = 50. (before the pre-2000 non-assessment period) ??? is non-assessment period same as initial condition period from fyear definition???
#' @param useTemp A boolean, if TRUE include temperature effects (e.g in S-R, growth, ect.), default = TRUE.
#' @param filenameCMIP The name of the input file containing temperature data, no default. !!! describe structure, see calc_Tanom
#' @param filenameDownscale The name of the input file of temperature data to downscale, no default. !!! describe structure, see calc_Tanom
#' @param tmods = NULL, # A string or vector of strings indicating what CMIP series to use (columns in filenameCMIP file), default = NULL uses all timeseries. !!! Need to make sure this is input data OR build in as .rda??? ## Do you want to use particular models from the cmip data series? If so tmods should be a vector of column names (see data/data_raw/NEUS_CMIP5_annual_meansLong.csv'). If NULL use all data
#' @param tq The temperature quantile of the cmip data series to use. default = 0.5 for median.
#' @param trcp Representative concentration pathway to use. Default = 8.5, currently only pathway available.
#' @param ref0 First reference year for temperature downscale, no default.
#' @param ref1 Last reference year for temperature downscale, no default.
#' @param baseTempYear Reference year for anomaly calculation, no default.
#' @param anomFun Function used in anomaly calculation (NOT a string), default = median.
#' @param BrefScalar Scalar to relate the calculated biomass reference point to the threshold value, default = 0.5.
#' @param FrefScalar Scalar to relate the calculated fishing mortality reference point to the threshold value, default = 0.75.
##### May want economic parameters to be provided in mproc when economic option turned on ??? for now arguments here
#' @param first_econ_yr First economic year, no default.
#' @param last_econ_yr Last economic year, no default.
#' @param last_econ_index Should calculate in setup section if economic section turned on, current default to difference between first and last econ year
#' @param econ_data_starts required to match first economic year???
#' @param econ_data_end required to match last economic year???
#' @param spstock2s # Define in economic section???
##### Independent variables in the targeting equation
# ??? Unclear what difference is between options for targeting equation?
##### Independent variables in the Production equation
# ??? Is it possible to combine these options (e.g. provide list where items in list vary based on option selected)
#' ##### Plot options
#' @param plotBrkYrs Years after management period begins to break up results for plotting, e.g. c(10,20) would result in plots of the first 0-10 years and 20-last year of the management period. No default.
#' @param plotBP A boolean, if TRUE generate boxplots of performance measures, default = FALSE.
#' @param plotRP A boolean, if TRUE generate extra folder of reference point plots, default = FALSE.
#' @param plotDrivers A boolean, if TRUE plot population drivers (e.g. temperature, recruitment, growth, selectivity), default = FALSE.
#' @param plotTrajInd A boolean, if TRUE plot samples of individual trajectories, default = FALSE.
#' @param plotTrajBox A boolean, if TRUE generate boxplots of trajectories, default = FALSE.
#' @param plotTrajSummary A boolean, if TRUE plot summary statistics, default = FALSE. 
#' 
#' @return 

runSim <- function(runHPCC = TRUE, # A boolean, if TRUE requires running the runPre.R script on HPCC, if FALSE set up results directory for local run. Default = FALSE. 
                   stockNames, # A string or vector of strings indicating what stocks to include (options: "codGB", "codGOM", "haddockGB", "pollock", "yellowtailflounderGB" to add new stockPar to available list provide newStockPar argument below), to use a mix of new and existing provide both stockNames for existing and newStockPar for new to use
                   newStockPar = NULL, # A string or vector of strings indicating the file path(s) to new stock parameter files, no default but example file available in templates folder ??? check that this folder accessible in R package, may need to provide link to templates folder on GitHub instead
                   mproc, #!!! not name of .csv file, name of object, you need to read in .csv when setting up sim
                   simpleTemperature = FALSE, # Debug using simple temperature trend that reduces variance? (T/F)
                   histAssess = TRUE,  #A boolean, if TRUE overwrite calculated values with historic assessment input values for each year, default = TRUE.
                   nrep = 1, # number of times to repeat this analysis, default = 1.
                   fmyear = NULL, # First year to begin actual management, no default.
                   fyear = NULL, # # first year after the initial condition period. The initial condition period # simply fills up the arrays as necessary even before the burn-in period # begins. This is rather arbitrary but should be larger than the number of # years in the assessment model and greater than the first age in the model.
                   mxyear = NULL, # maximum year predicted into the future, no default, ??? depend on length of temp timeseries???
                   nburn = 50, # number of burn-in years (before the pre-2000 non-assessment period) ??? is non-assessment period same as initial condition period from fyear definition???
                   useTemp = TRUE, # A boolean, if TRUE include temperature effects (e.g in S-R, growht, ect.)
                   tmods = NULL, # A string or vector of strings indicating what CMIP series to use, default = NULL uses all timeseries. !!! Need to make sure this is input data OR build in as .rda??? ## Do you want to use particular models from the cmip data series? If so tmods should be a vector of column names (see data/data_raw/NEUS_CMIP5_annual_meansLong.csv'). If NULL use all data
                   tq = 0.5, # The temperature quantile of the cmip data series to use. default = 0.5 for median.
                   trcp = 8.5, # Representative concentration pathway to use. Default = 8.5, currently only pathway available.
                   ref0 = NULL, # First reference year for temperature downscale, no default.
                   ref1 = NULL, # Last reference year for temperature downscale, no default.
                   baseTempYear = NULL, # Reference year for anomaly calculation, no default.
                   filenameCMIP = NULL, # The name of the input file containing temperature data, no default.
                   filenameDownscale = NULL, 
                   anomFun = median, # Function used in anomaly calculation, default = median.
                   BrefScalar = 0.5, # Scalar to relate the calculated biomass reference point to the threshold value, default = 0.5.
                   FrefScalar = 0.75, # Scalar to relate the calculated fishing mortality reference point to the threshold value, default = 0.75.
                   ##### May want economic parameters to be provided in mproc when economic option turned on ??? for now arguments here
                   first_econ_yr = NULL, # First economic year
                   last_econ_yr = NULL, # Last economic year
                   last_econ_index = last_econ_yr-first_econ_yr+1, # Should calculate in setup section if economic section turned on
                   econ_data_starts = NULL, # required to match first economic year???
                   econ_data_end = NULL, # required to match last economic year???
                   spstock2s=c("americanlobster","americanplaiceflounder","codGB","codGOM","haddockGB","haddockGOM","monkfish", "other","pollock","redsilveroffshorehake","redfish","seascallop","skates","spinydogfish","squidmackerelbutterfishherring","summerflounder","whitehake","winterflounderGB","winterflounderGOM","witchflounder","yellowtailflounderCCGOM", "yellowtailflounderGB","yellowtailflounderSNEMA"), # Define in economic section???
                   ##### Independent variables in the targeting equation
                   # ??? Unclear what difference is between options for targeting equation?
                   ##### Independent variables in the Production equation
                   # ??? Is it possible to combine these options (e.g. provide list where items in list vary based on option selected)
                   ##### Plot options
                   plotBrkYrs = NULL, # Years after management period begins to break up results for plotting, e.g. c(10,20) would result in plots of the first 0-10 years and 20-last year of the management period.
                   plotBP = FALSE, # A boolean, if TRUE generate boxplots of performance measures, default = FALSE.
                   plotRP = FALSE, # A boolean, if TRUE generate extra folder of reference point plots, default = FALSE.
                   plotDrivers = FALSE, # A boolean, if TRUE plot population drivers (e.g. temperature, recruitment, growth, selectivity), default = FALSE.
                   plotTrajInd = FALSE, # A boolean, if TRUE plot samples of individual trajectories, default = FALSE.
                   plotTrajBox = FALSE, # A boolean, if TRUE generate boxplots of trajectories, default = FALSE.
                   plotTrajSummary = FALSE, # A boolean, if TRUE plot summary statistics, default = FALSE. 
                   
                   
                   
){
  
  ###### Below from set_om parameters
  #### Output ####
  # Which sets of plots should be created? Set these objects to T/F

  #how many years before writing out the results to csv? 6 corresponds to 1 "econ" simulation (2010-2015).  Larger will go faster (less overhead) but you lose work if something crashes,
  savechunksize<-10
  
  #Set up a counter for every year that has been simulated ??? How used, maybe this should be in simulation?
  yearcounter<-0
  
  #Set up a list to hold the economic results !!! Only set this up if economic model included
  revenue_holder<-list()
  #these two lists will hold a vectors that concatenates (r, m, y, calyear, .Random.seed). They should be r*m*y in length.
  begin_rng_holder<-list()
  end_rng_holder<-list()
  
  # #### Stock parameters ####
  # # If you have files in the modelParameters folder for stocks but you don't
  # # want to include them in a run you can write them in here in the
  # # stockExclude variable. Do not include the extension.R. For example,
  # # stockExclude <- 'haddockGB' (string) will leave haddockGB.R out of the analysis.
  # # stockExclude <- NULL indludes all stocks.
  # # Available stocks: haddockGB, codGOM, codGB, pollock, yellowtailflounderGB
  # stockExclude <- c('haddockGB', 'codGB', 'pollock', 'yellowtailflounderGB') # - changed so instead provide stockNames
  
  # Number of model years to run are defined by the length of the burn-in ??? Where are these defined if not in OM parameters/as input argument???
  # period and the dimension of the CMIP5 data set.
  # Load the cmip5 temperature data
  # cmip5 <- read.table(file='data/data_raw/NEUS_CMIP5_annual_means.txt',
  #                     header=TRUE, skip=2)
  # cmip5 <- subset(cmip5, year <= mxyear)
  
  # nyear <- nrow(cmip5) + nburn

  ##############Independent variables in the targeting equation ##########################
  ### If there are different targeting equations, you can set there up here, then use their suffix in the mproc file to use these new targeting equations
  ### example, using ChoicEqn=small in the mproc file and uncommenting the next two lines will be appropriate for a logit with just 3 RHS variables.
  
  ##spstock_equation_small=c("exp_rev_total", "fuelprice_distance")
  ##choice_equation_small=c("fuelprice_len")
  spstock_equation_pre=c("exp_rev_total", "fuelprice_distance", "distance", "mean_wind", "mean_wind_noreast", "permitted", "lapermit", "choice_prev_fish", "partial_closure", "start_of_season")
  choice_equation_pre=c("wkly_crew_wage", "len", "fuelprice", "fuelprice_len")
  
  spstock_equation_post<-spstock_equation_pre
  choice_equation_post<-choice_equation_pre
  ############## End Independent variables in the targeting equation ##########################
  
  ##############Independent variables in the Production equation ##########################
  ### If there are different the equations, you can set there up here, then use their suffix in the mproc file to use these new targeting equations
  ### example, using ProdEqn=tiny in the mproc file and uncommenting the next  line will be regression with 2 RHS variables and no constant.
  # production_vars_tiny=c("log_crew","log_trip_days")
  
  production_vars_pre=c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","constant")
  production_vars_post=c("log_crew","log_trip_days","primary","secondary", "log_trawl_survey_weight","log_sector_acl", "constant")
  ############## End Independent variables in the Production equation ##########################
  
  
  
  
  
  


#### Set up environment ####
# Empty the environment and setup simulation
rm(list=ls())

# runPre - code for setting up storage, Same process performed by runPre.R script for HPCC
if(runHPCC == FALSE){
  # Set run class
  runClass <- 'Local'
  
  # ID platform (used to manage different operating systems) - previously sourced processes/get_runinfo.R
  platform <- Sys.info()['sysname']
  
  # Ensure that TMB will use the Rtools compiler (only windows ... and 
  # not necessary on all machines) ???
  # If platform != Linux
  if(platform == 'Windows'){
    path_current <- Sys.getenv('PATH')
    path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                       path_current)
    Sys.setenv(PATH=path_new)
  } else if(platform == 'Darwin'){
    path_current <- Sys.getenv('PATH')
  } else if(platform == 'Linux'){
    # !!!! Currently missing option for local Linux machines
  }
  
  # Remove all files (as long as not running runSetup later within the plotting
  # function to gather information for diagnostic plots). Ran through the 
  # available environments before and after the simulation is run and found
  # one variable that was only available after (active_idx) ... used that to
  # determine whether or not to delete all the files in the results directory. ???
  
  # Create new results directory tagged with date/time
  # Get and format the system time
  time <- Sys.time()
  timeString <- format(x = time, 
                       format = "%Y-%m-%d-%H-%M-%S")
  # Define a directory name
  ResultDirectory <- paste('results', timeString, sep='_')
  dir.create(ResultDirectory, showWarnings = FALSE, recursive=TRUE)
  # Results folders for economic models. Create them if necessary
  
  # Generate directories for economic results if economic model used
  if(econModel == TRUE){
    econ_results_location<-file.path(ResultDirectory,"econ","raw")
    dir.create(econ_results_location, showWarnings = FALSE, recursive=TRUE)
  }

  # Generate directories for simulation results and accompanying figures
  dir.create(file.path(ResultDirectory,"sim"), showWarnings = FALSE, recursive=TRUE)
  dir.create(file.path(ResultDirectory,"fig"), showWarnings = FALSE, recursive=TRUE)
  
  # Compile the c++ file and make available to R
  TMB::compile("assessment/caa.cpp")
  
} else{ # Else this setup occurs by sourcing runPre.R script on HPCC
  # Set run class
  runClass <- 'HPCC'
}
  
  
# source('processes/runSetup.R')
Setup <- runSetup(ResultDirectory = ResultDirectory)

# Set global variables from setup
stockPar <- Setup$stockPar 
stockNames <- Setup$stockNames 
stock <- Setup$stock 
nstock <- length(stockNames)
tAnomOut <- Setup$tAnomOut 
yrs <- Setup$yrs
nyear <- Setup$nyear
yrs_temp <- Setup$yrs_temp
fmyearIdx <- Setup$fmyearIdx

# # I think that we probably want the executable attached as in the WHAM package rather than compiling the executable here (we could include a copy of the uncompiled code for reference as a text file in the package)
# # if on local machine (i.e., not hpcc) must compile the tmb code
# # (HPCC runs have a separate call to compile this code). Keep out of
# # runSetup.R because it is really a separate process on the HPCC.
# if(runClass != 'HPCC'){
#   source('processes/runPre.R', local=ifelse(exists('plotFlag'), TRUE, FALSE)) #??? I don't think plotFlag exists/is used anymore
# }

#### Helpful parameters ####
# Scalars to convert things
pounds_per_kg <- 2.20462
kg_per_mt <- 1000

####################These are temporary changes for testing ####################
# econ_timer<-0

#  mproc_bak<-mproc
#
# mproc<-mproc_bak[5:5,]
# nrep<-1
# nyear<-200
## For each mproc, I need to randomly pull in some simulation data (not quite right. I think I need something that is nrep*nyear long.  Across simulations, each replicate-year gets the same "econ data"
####################End Temporary changes for testing ####################

#### Set up year indexing ####
#This depends on mproc, fyear, and nyear. So it should be run *after* it is reset. I could be put in the runSetup.R script. But since I'm  adjusting fyear and nyear temporarily, I need it here (for now).

source('processes/setupYearIndexing.R')

#### Set up time variables, random seed, progress bar ####
#set the rng state based on system time.  Store the random state.
# if we use a plain old date (seconds since Jan 1, 1970), the number is actually too large, but we can just rebase to seconds since Jan 1, 2018.
start<-Sys.time()-as.POSIXct("2018-01-01 00:00:00", "%Y-%m-%d %H:%M:%S")
start<-as.double(start)*100
# set.seed(start)

oldseed_ALL <- .Random.seed
showProgBar <- TRUE

top_loop_start <- Sys.time()

#### Top rep Loop ####
for(r in 1:nrep){
    # oldseed_mproc <- .Random.seed

  #### Top MP loop ####
  for(m in 1:nrow(mproc)){

       manage_counter <- 0

       #Restore the rng state.  Depending on whether you use oldseed1 or oldseed2, you'll get different behavior.  oldseed_ALL will force all the replicates to start from the same RNG state.  oldseed_mproc will force all the management procedures to have the same RNG state.  You probably want oldseed_mproc
       #.Random.seed<-oldseed_ALL
       # .Random.seed<-oldseed_mproc

        #the econtype dataframe will pass a few things through to the econ model that govern how fishing is turned on/off when catch limits are reached, which sets of coefficients to use, and which prices to use
        if(mproc$ImplementationClass[m]=="Economic"){
          
         source('processes/setupEconType.R') #!!! revisit
        }
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
        stock[[i]] <- get_J1Updates(stock = stock[[i]], 
                                    y = y, 
                                    fmyearIdx = fmyearIdx, 
                                    histAssess = histAssess)
      }

      source('processes/withinYearAdmin.R')
      begin_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)

      # if burn-in period is over...
      if(y >= fmyearIdx){

        manage_counter<-manage_counter+1 #this only gets incremented when y>=fmyearIdx

        for(i in 1:nstock){
          stock[[i]] <- get_advice(stock = stock[[i]], mproc = mproc, y = y, m = m,
                                   yrs = yrs,  yrs_temp = yrs_temp, fmyearIdx = fmyearIdx,
                                   Tanom = Tanom, rep = rep, sty = sty, planBest = planBest, 
                                   res = res, rundir = rundir, temp = temp)
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
                                              stock = stock[[i]])
          } # End implementation error in standard fisheries
        }else{
          #Add a warning about invalid ImplementationClass
        }

        for(i in 1:nstock){
          if (y == nyear){
            stock[[i]] <- get_TermrelError(stock = stock[[i]])
          }
          stock[[i]] <- get_fillRepArrays(stock = stock[[i]])
        }
      } #End of burn-in loop
      for(i in 1:nstock){
        stock[[i]] <- get_mortality(stock = stock[[i]], y=y)
        stock[[i]] <- get_indexData(stock = stock[[i]], y=y, Tanom=Tanom, fmyearIdx=fmyearIdx)
      } #End killing fish loop

      end_rng_holder[[yearitercounter]]<-c(r,m,y,yrs[y],.Random.seed)

          #Save economic results once in a while to a csv file.
        if(mproc$ImplementationClass[m]=="Economic" &(y >= fmyearIdx) & (chunk_flag==0 | yearitercounter==max_yiter)) {
            revenue_holder<-rbindlist(revenue_holder)
            tda <- as.character(Sys.time())
            tda <- gsub(':', '', tda)
            tda<-gsub(' ', '_', tda)
            tda2 <- paste0(tda,"_", round(runif(1, 0, 10000)))
            write.table(revenue_holder, file.path(econ_results_location, paste0("econ_",tda2, ".csv")), sep=",", row.names=FALSE)
            revenue_holder<-list()
        } #End save economic results if statement

        if(showProgBar==TRUE){
          setTxtProgressBar(iterpb, yearitercounter)
        }
    }
       #End of year loop
  } #End of mproc loop



} #End rep loop

top_loop_end<-Sys.time()
big_loop<-top_loop_end-top_loop_start
big_loop
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
    pth <- paste0(Setup$ResultDirectory,'/fig/', sapply(stock, '[[', 'stockName')[i])
    dir.create(pth, showWarnings = FALSE)
  }


  #### save results ####
  omvalGlobal <- sapply(1:nstock, function(x) stock[[x]]['omval'])
  names(omvalGlobal) <- sapply(1:nstock, function(x) stock[[x]][['stockName']])
  save(omvalGlobal, file=paste0(Setup$ResultDirectory,'/sim/omvalGlobal', td2, '.Rdata'))

  if(runClass != 'HPCC'){
    omparGlobal <- readLines('modelParameters/set_om_parameters_global.R')
    cat('\n\nSuccess.\n\n',
        'Completion at: ',
        td,
        file=paste0(Setup$ResultDirectory,'/runInfo.txt'))
    cat('\n\n\n\n\n\n\n\n  ##### Global OM Parameters ##### \n\n',
        omparGlobal,
        file=paste0(Setup$ResultDirectory,'/runInfo.txt'), sep='\n', append=TRUE)
    for(i in 1:nstock){
      cat('\n\n\n\n\n\n\n\n  ##### Stock OM Parameters ##### \n\n',
          readLines(fileList[i]),
          file=paste0(Setup$ResultDirectory,'/runInfo.txt'), sep='\n', append=TRUE)
    }
  }



  if(runClass != 'HPCC'){
    # Note that runPost.R re-sets the containers; results have already been
    # saved however.
    source('processes/runPost.R')
  }


  print(unique(warnings()))

  cat('\n ---- Successfully Completed ----\n')
}
