

# Run simulation setup. This is a separate file so that the model setup
# parameters canj later be accessed by running the setup but not the
# entire simulation.

# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))


# prepare directories
#prepFiles()


# Get the run info so the functions work appropriately whether they are
# on Windows or Linux and whether this is an HPCC run or not.
source('processes/get_runinfo.R')

# load the required libraries
source('processes/loadLibs.R')

# load the list of management procedures
source('processes/generateMP.R')

# get the operating model parameters
source('processes/set_om_parameters.R')

# Load specific recruitment functions for simulation-based approach
# to Bproxy reference points
source('processes/Rfun_BmsySim.R')

# If running on a local machine, more than one repetition should be
# used otherwise some plotting functions (e.g., boxplots) will fail
if(runClass == 'Local' && nrep == 1){
  stop('For local runs please set nrep > 1 (in set_om_parameters.R)',
       call.=FALSE)
}

# Load in the baseline projected temperature data to use
cmip_base <- cmip5[,c('year', cmip5model)]
names(cmip_base) <- c('YEAR', 'T')

# Load in the GB temperature data for downscaling
load('data/data_raw/mqt_oisst.Rdata')
gbT <- mqt_oisst[,c('Year', 'q1')]
names(gbT) <- c('YEAR', 'T')

# Downscale from NELME to GB
cmip_dwn <- get_temperatureProj(prj_data = cmip_base, 
                                obs_data = gbT, 
                                ref_yrs = c(ref0, ref1))

# Get the temperature vector
msyears <- cmip_dwn$YEAR < 2000
if(useTemp == TRUE){
  temp <- c(rep(median(cmip_dwn[msyears,'T']), nburn),
            cmip_dwn[,'T'])
  anomStd <- median(cmip_dwn[msyears,'T'])  # anomoly standard
  Tanom <- temp - anomStd
}else{
  temp <- NULL
  Tanom <- rep(0, nburn+length(cmip_dwn[,'T']))
}

# The first year that actual management will begin
fmyear <- nburn + sum(msyears)


# get all the necessary containers for the simulation
source('processes/get_containers.R')

# if on local machine (i.e., not hpcc) must compile the tmb code
# (HPCC runs have a separate call to compile this code).
if(runClass != 'HPCC'){
  source('processes/runPre.R')
}

# Set up a sink for debugging -- don't use this if on the HPCC because
# you will end up with multiple programs trying to access the same file
# at the same time (if running in paralell).
if(debugSink & runClass != 'HPCC'){
  dbf <- 'results/debugInfo.txt'
  cat('############  Debug results:  ############\n',
      file=dbf, sep='')
  
  # Keep console reasonably clean
}

