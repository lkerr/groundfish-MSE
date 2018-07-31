

# Determine what platform the code is running on (Duplicated purposefully
# in runPre.R & runPost.R for running on HPCC)
platform <- Sys.info()['sysname']

# Determine whether or not this is a run on the HPCC by checking for the
# existence of the folder Rlib. Duplicate of code in runSim.R but this is
# necessary because runPre.R & runPost.R are run separately when run on 
# the HPCC.
if(file.exists('../Rlib')){
  runClass <- 'HPCC'
}else{
  runClass <- 'Local'
}


# Load in the simulation results
fl <- list.files('results/sim/', full.names=TRUE)

# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

# load the required libraries
source('processes/loadLibs.R')

flLst <- list()
for(i in 1:length(fl)){
  load(fl[i])
  flLst[[i]] <- omval
}

omval <- get_simcat(x=flLst)
names(omval) <- names(flLst[[1]])

get_plots(x=omval, dirOut='results/fig/')
