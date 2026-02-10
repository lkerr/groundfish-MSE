# Run simulation setup. This is a separate file so that the model setup
# parameters can later be accessed by running the setup but not the
# entire simulation.

# load all the functions
ffiles <- list.files(path='functions/', pattern="^.*\\.R$",full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

# Get the result directory path
source('processes/runPre.R')
source('processes/identifyResultDirectory.R')

# Load the overall operating model parameters
source('modelParameters/set_om_parameters_global.R')
source('modelParameters/wham_settings.R')

# get the operating model parameters -- first search the space for every
# version of the set_stock_parameters_xx files and put them in this list.
fileList <- list.files('modelParameters/stockParameters', full.names=TRUE)
if(!is.null(stockExclude)){
  stockExclude <- paste0(stockExclude, '.R')
  rem <- match(stockExclude, basename(fileList))
  if(any(is.na(rem))){
    stop(paste('run_setup.R: check names of excluded stocks in', 
               'set_om_parameters_global file and be sure they match the actual', 
               'stock file names'))
  }
  fileList <- fileList[-rem]
  if(length(fileList) < 1){
    stop(paste('run_setup.R: check names of excluded stocks in', 
               'set_om_parameters_global file. It looks like you have',
               'removed all available stocks.'))
  }
}

# Retrieve the stock names from the file paths
stockNameListExt <- sapply(fileList, basename)
stockNameList <- unname(sapply(stockNameListExt, sub, 
                               pattern='\\.R$', replacement=''))

nstock <- length(fileList)
stockPar <- as.list(nstock)
for(i in 1:nstock){
  tempEnv <- new.env()
  source(fileList[[i]], local = tempEnv)
  # Calculate number of ages (needed for other variables)
  tempEnv$nage <- length(tempEnv$fage:tempEnv$page)
  # Add name of stock for labeling objects and plots
  tempEnv$stockName <- stockNameList[i]
  stockPar[[i]] <- as.list(tempEnv)
  rm(tempEnv)
}

# Get the names of each stock (stocks must follow naming convention)
stockNames <- unname(sapply(fileList, function(x) 
  strsplit(x, 'stockParameters/|\\.R')[[1]][2]))

# Indicate this is a HPCC run
runClass<- 'HPCC'

# load the required libraries
source('processes/loadLibs.R')

# load the list of management procedures
source('processes/generateMP.R')

# Model structure (includes loading in temperature data)
source('processes/genAnnStructure.R')

# Load specific recruitment functions
# approach to deriving Bproxy reference points
source('processes/Rfun_BmsySim.R')

# Load default ACLs and fractions of the ACL that are allocated to the catch share fishery
source('processes/genBaselineACLs.R')

#Create directories for results 
dir.create('results/sim', showWarnings = FALSE, recursive=TRUE)
dir.create('results/fig', showWarnings = FALSE, recursive=TRUE)

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
  stockCont[[i]] <- get_containers(stockPar=stockPar[[i]])
}

# Combine the stock parameters and the stock containers into a single list
stock <- list()
for(i in 1:nstock){
  stock[[i]] <- c(stockPar[[i]], stockCont[[i]])
}
names(stock) <- stockNames

# Ensure that there are enough initial data points to support the
# index generation at the beginning of the model.
mxModYrs <- max(sapply(stock, '[[', 'ncaayear'))
if(fyear < mxModYrs){
  stop(paste('fyear is less than the maximum number of years used',
             'for assessment for one of the stocks (ensure that fyear',
             'in the global parameters file is less than ncaayear for',
             'each stock'))
}


