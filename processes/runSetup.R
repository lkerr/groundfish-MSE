
# Run simulation setup. This is a separate file so that the model setup
# parameters can later be accessed by running the setup but not the
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
nage <- length(fage:page)

source('processes/genAnnStructure.R')

# Load specific recruitment functions for simulation-based approach
# to Bproxy reference points
source('processes/Rfun_BmsySim.R')

# If running on a local machine, more than one repetition should be
# used otherwise some plotting functions (e.g., boxplots) will fail
if(runClass == 'Local' && nrep == 1){
  stop('For local runs please set nrep > 1 (in set_om_parameters.R)',
       call.=FALSE)
}



# get all the necessary containers for the simulation
source('processes/get_containers.R')



# Set up a sink for debugging -- don't use this if on the HPCC because
# you will end up with multiple programs trying to access the same file
# at the same time (if running in paralell).
if(debugSink & runClass != 'HPCC'){
  dbf <- 'results/debugInfo.txt'
  cat('############  Debug results:  ############\n',
      file=dbf, sep='')
}






