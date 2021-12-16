# !!! inherit parameter definition from runSim or vice versa
# Run simulation setup. This is a separate file so that the model setup
# parameters can later be accessed by running the setup but not the
# entire simulation.
#'
#' @inheritParams runSim # Inherit parameter definitions from runSim
#'
#' @return A list containing the following:
#' \itemize{
#'   \item{ResultDirectory - The name of the directory in which results will be stored (a string).}
#'   \item{stockPar - A list of stock parameters for each stock in stockNames, for multiple stocks this is a list of lists.}
#'   \item{stockNames - An updated vector of stock names based on input species and new stock parameter files (if no files provided, returns input).}
#'   \item{stock - A storage object containing initial stock parameters (from stock) and storage for each stock's simulation results.}
#'   \item{tAnomOut - A matrix containing columns for "YEAR", temperature "T", downscaled temperature "DOWN_T", temperature anomaly "TANOM" and corresponding standard deviation "TANOM_STD"}
#'   \item{yrs - A vector of calendar years from firstYear to mxyear, set in processes/genAnnStructure.R}
#'   \item{nyear - The number of years based on available temperature data set in processes/genAnnStructure.R}
#'   \item{yrs_temp - A vector of years from firstYear to the maximum year in the cmip5 temperature timeseries, set in processes/genAnnStructure.R.}
#'   \item{fmyearIdx - An index for the year that management begins, from processes/genAnnStructure.R}
#' }
#' 
#' @example 
#' stockNames <- c("codGB", "haddockGB")
#' newStockPar <- "templates/template_newStockPar.R"
#' runSetup(stockNames = stockNames, newStockPar = newStockPar, filenameCMIP = filenameCMIP, filenameDownscale = filenameDownscale,fmyear = 2019, ref0 = 1982, ref1 = 2020, baseTempYear = 1985)


runSetup <- function(stockNames,
                     newStockPar = NULL,
                     filenameCMIP = NULL,
                     filenameDownscale = NULL,
                     fmyear = NULL,
                     trcp = 8.5,
                     tmods = NULL,
                     tq = 0.5,
                     ref0 = NULL,
                     ref1 = NULL,
                     baseTempYear = NULL,
                     nburn = 50,
                     anomFun = median){
  
  # # load all the functions - no longer needed, loaded when R package loaded
  # ffiles <- list.files(path='functions/', pattern="^.*\\.R$",full.names=TRUE, recursive=TRUE)
  # invisible(sapply(ffiles, source))
  
  # Get the result directory path
  # source('processes/identifyResultDirectory.R')
  ResultDirectory <- identifyResultDirectory()
  
  # # Load the overall operating model parameters - loaded as arguments to runSim, turn this script into the example script
  # source('modelParameters/set_om_parameters_global.R')
  
  
  # # get the operating model parameters -- first search the space for every
  # # version of the set_stock_parameters_xx files and put them in this list.
  # fileList <- list.files('modelParameters/stockParameters', full.names=TRUE)
  # if(!is.null(stockExclude)){
  #   stockExclude <- paste0(stockExclude, '.R')
  #   rem <- match(stockExclude, basename(fileList))
  #   if(any(is.na(rem))){
  #     stop(paste('run_setup.R: check names of excluded stocks in', 
  #                'set_om_parameters_global file and be sure they match the actual', 
  #                'stock file names'))
  #   }
  #   fileList <- fileList[-rem]
  #   if(length(fileList) < 1){
  #     stop(paste('run_setup.R: check names of excluded stocks in', 
  #                'set_om_parameters_global file. It looks like you have',
  #                'removed all available stocks.'))
  #   }
  # }
  
  # If no new stock parameter file provided, load existing stock options and filter based on those selected
  if(is.null(newStockPar)){
    fullStockPar <- groundfishMSE::stockPar # until package built can run: load("~/Research/groundfish-MSE/data/stockPar.rda") AND fullStockPar <- stockPar
    stockPar <- fullStockPar[stockNames]
  } else{ # Read in new stock parameters from file, append to existing stock list, then select stocks
    # Load existing stocks and pick those listed for use
    fullStockPar <- groundfishMSE::stockPar # until package built can run: load("~/Research/groundfish-MSE/data/stockPar.rda") AND fullStockPar <- stockPar
    pickStockPar <- fullStockPar[stockNames]
    
    # Retrieve the stock names from the new stock parameter file paths 
    fileList <- newStockPar # provide list of new stock parameter files
    stockNameListExt <- sapply(fileList, basename)
    stockNameList <- unname(sapply(stockNameListExt, sub, 
                                   pattern='\\.R$', replacement=''))
    
    # Read in new stocks, stocks automatically inherit names from source parameter file
    nstock <- length(fileList)
    stockPar <- as.list(nstock)
    for(i in 1:nstock){
      # Process file in temporary environment
      tempEnv <- new.env()
      source(fileList[[i]], local = tempEnv) 
      # Calculate number of ages (needed for other variables)
      tempEnv$nage <- length(tempEnv$fage:tempEnv$page)
      # Add name of stock for labeling objects and plots
      tempEnv$stockName <- stockNameList[i]
      stockPar[[stockNameList[i]]] <- as.list(tempEnv) 
      rm(tempEnv)
      # Append to existing stock list
      pickStockPar[[stockNameList[i]]] <- stockPar
    }
    
    # If using a combination of existing & new stocks append existing to list
    if(is.null(stockNames) == FALSE){
      # Append existing stocks to list
      for(istock in 1:length(stockNames)){
        stockPar[[stockNames[istock]]] <- pickStockPar[[istock]]
      }
    }
    
    # Update list of stock names with new stocks & reset nstock based on length of stockNames (now includes all stocks of interest)
    stockNames <- c(stockNames, stockNameList)
    nstock <- length(stockNames)
  } # End if/else to load new stock data  
  
  # # Get the names of each stock (stocks must follow naming convention)
  # stockNames <- unname(sapply(fileList, function(x) 
  #   strsplit(x, 'stockParameters/|\\.R')[[1]][2]))
  
  # # save list of stockParameters as external data (.rda file in data folder) for all species for R package
  # usethis::use_data(stockPar, internal = FALSE)
  # # May reference internally in code as groundfishMSE::stockPar # may need to rebuild package to reference in this manner
  
  # Get the run info so the functions work appropriately whether they are
  # on Windows or Linux and whether this is an HPCC run or not.
  source('processes/get_runinfo.R') # !!!circle back to this
  
  # # load the required libraries - replaced by DESCRIPTION, all packages loaded with R package as dependencies/required
  # source('processes/loadLibs.R')
  
  
  # # load the list of management procedures - I think same info now provided as mproc argument !!! confirm
  # source('processes/generateMP.R')
  
  # # Model structure (includes loading in temperature data) - replaced with function call to calc_Tanom
  # source('processes/genAnnStructure.R')
  
  # Load and process temperature data, use to return year information
  calc_Tanom(filenameCMIP = filenameCMIP, 
             filenameDownscale = filenameDownscale,
                         fmyear = fmyear,
                         trcp = trcp,
                         tmods = tmods,
                         tq = tq,
                         ref0 = ref0,
                         ref1 = ref1,
                         baseTempYear = baseTempYear,
                         nburn = nburn,
                         anomFun = anomFun,
             useTemp = TRUE, 
             simpleTemperature = FALSE)
  
  # Load specific recruitment functions (these are a list for simulation-based 
  # approach to deriving Bproxy reference points
  source('processes/Rfun_BmsySim.R') # !!! revisit
  
  # Load default ACLs and fractions of the ACL that are allocated to the catch share fishery
  source('processes/genBaselineACLs.R')
  
  #Input data location for economic models !!!!!! May want to put this economic setup in an econSetup function (also include if statement at top of runSim to setup data storage, ect.)
  econdatapath <- 'data/data_processed/econ'
  
  # Reults folders for economic models. Create them if necessary
  econ_results_location<-"results/econ/raw"
  dir.create('results/econ/raw', showWarnings = FALSE, recursive=TRUE)
  dir.create('results/sim', showWarnings = FALSE, recursive=TRUE)
  dir.create('results/fig', showWarnings = FALSE, recursive=TRUE)
  
  # If running on a local machine, more than one repetition should be
  # used otherwise some plotting functions (e.g., boxplots) will fail
  if(runClass == 'Local' && nrep == 1){
    # stop('For local runs please set nrep > 1 (in set_om_parameters.R)',
    # call.=FALSE)
    nrep <- 2
    warning('local run: nrep (in set_om_parameters.R) set to 2 to avoid errors')
  }
  
  # # Warning regarding Bmsy calculation hindcasts
  # tst <- !is.na(mproc$BREF_TYP) & 
  #        mproc$BREF_TYP == 'SIM' &
  #        mproc$RFUN_NM == 'hindcastMean' &
  #        mproc$BREF_PAR0 > ncaayear
  # if(any(tst)){
  #   msg <- paste0('Number of years in hindcast that you specified (', 
  #                 mproc$BREF_PAR0[tst], ') is larger than the number of years in', 
  #                 ' the moving window of the stock assessment model (', 
  #                 ncaayear, '). Number of years used in the hindcast changed to ', 
  #                 ncaayear, '.\n')
  #   warning(msg)
  # }
  
  # Error regarding bad combinations of mproc
  tst <- mproc$BREF_TYP == 'RSSBR' & mproc$RFUN_NM == 'forecast'
  if(!all(is.na(tst)) && any(tst & !is.na(tst))){
    stop(paste('In mproc BREF_TYP and RFUN_NM cannot be RSSBR and forecast,',
               'respectively. While this may be possible to compute it seems',
               'odd to use future SSB in the calculation of R for R*SSBR',
               'but then not include SSB projections when thinking about what',
               'the reference point should actually be.'))
  }
  
  # Error regarding number of years.
  inTest <- (plotBrkYrs + fmyearIdx) %in% (fmyearIdx+1):nyear
  if(!all(inTest)){
    stop(paste('check plotBrkYrs in set_om_parameters_global. One or more',
               'of your break years is outside the possible range.'))
  }
  
  
  # get all the necessary containers for the simulation
  stockCont <- list()
  for(i in 1:nstock){
    stockCont[[i]] <- get_containers(stockPar=stockPar[[stockNames[i]]], # Reference by name given in above processing but assign to number to avoid future conflicts/errors
                                     nyear = nyear,
                                     fyear = fyear,
                                     nburn = nburn,
                                     mproc = mproc,
                                     nrep = nrep)
  }
  
  # Combine the stock parameters and the stock containers into a single list
  stock <- list()
  for(i in 1:nstock){
    stock[[i]] <- c(stockPar[[stockNames[i]]], stockCont[[i]])
  }
  names(stock) <- stockNames 
  
  
  # Set up a container dataframe for Fleet-level Economic Results
  # These are simulation specific so they are stored in a single dataframe
  source('processes/genEcon_Containers.R') #!!! May also want to put in if statement so only run if economic model set up
  
  
  # Ensure that there are enough initial data points to support the
  # index generation at the beginning of the model.
  mxModYrs <- max(sapply(stock, '[[', 'ncaayear'))
  if(fyear < mxModYrs){
    stop(paste('fyear is less than the maximum number of years used',
               'for assessment for one of the stocks (ensure that fyear',
               'in the global parameters file is less than ncaayear for',
               'each stock'))
  }
  
  if (platform == 'Linux'){ # !!! Again if this is setup for the HPCC run this line could prevent running on local Linux machine
    if(!file.exists('../EXE/ASAP3.EXE')){
      stop(paste('ASAP3.EXE should be loaded in a directory EXE in the parent',
                 'directory of groundfish-MSE -- i.e., you need an EXE',
                 'directory in the same directory as Rlib and EXE must contain',
                 'ASAP3.EXE', sep='\n'))
    }
    rand <- sample(1:10000, 1)
    tempwd <- getwd()
    rundir <- paste(tempwd, "/assessment/ASAP/Run", '_', rand, sep = "")
    dir.create(path = rundir)
    from.path <- paste('../EXE/ASAP3.EXE', sep = "")
    to.path   <- paste(rundir, sep= "")
    file.copy(from = from.path, to = to.path)
  }
  
  # Setup return list
  setup <- NULL
  setup$ResultDirectory <- ResultDirectory # A string for the results directory name
  setup$stockPar <- stockPar # !!! not yet fed back into runSim - this is a subset of stock (which also contains storage containers that get populated in the simulation)
  setup$stockNames <- stockNames # updated list of stock names based on new stock parameter files (if no files provided, returns input) #!!! not yet fed back into runSim
  setup$stock <- stock # A storage object containing initial stock parameters and storage for simulation results
  # From calc_Tanom
  setup$tAnomOut <- tAnomOut 
  setup$yrs <- yrs
  setup$nyear <- nyear
  setup$yrs_temp <- yrs_temp
  setup$fmyearIdx <- fmyearIdx
  
  return(setup)
}
