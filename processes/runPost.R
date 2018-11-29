

# Get the run info so the functions work appropriately whether they are
# on Windows or Linux and whether this is an HPCC run or not.
source('processes/get_runinfo.R')


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


mproc <- read.table('processes/mproc.txt', header = TRUE,
                    stringsAsFactors = FALSE)
get_memUsage(runClass = runClass, info=mproc)
