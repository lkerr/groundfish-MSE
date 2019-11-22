

# Get the result directory path
source('processes/identifyResultDirectory.R')

# Get the run info so the functions work appropriately whether they are
# on Windows or Linux and whether this is an HPCC run or not.
# source('processes/get_runinfo.R')
source('processes/runSetup.R')


# Load in the simulation results
fl <- list.files(file.path(ResultDirectory, 'sim'), full.names=TRUE)

# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

# load the required libraries
source('processes/loadLibs.R')

flLst <- list()
for(i in 1:length(fl)){
  load(fl[i])
  flLst[[i]] <- omvalGlobal
  names(flLst[[i]]) <- names(omvalGlobal)
}

for(i in 1:length(flLst[[1]])){

  omval <- get_simcat(x=lapply(flLst, '[[', i))
  names(omval) <- names(flLst[[1]][[i]])
  stknm <- names(flLst[[1]])[i]
  
  # The "year" list element in omval is for plotting and needs to be
  # only the length of the number of years -- unlike the other categories
  # this doesn't change. So plotting doesn't get result in errors, change
  # the dimensions of this list element
  omval[['YEAR']] <- omval[['YEAR']][1:(length(omval[['YEAR']])/length(flLst))]
  
  dirOut <- paste0(ResultDirectory, '/fig/', stknm, '/')

  get_plots(x=omval, stockEnv = stockPar[[i]], 
            dirIn=paste0(ResultDirectory, '/sim/'), dirOut=dirOut)

}

# Output the management procedures text file in the figure directory
get_catdf(df = mproc, file = paste0(ResultDirectory,'/fig/',mprocfile)

# Output the memory usage
get_memUsage(runClass = runClass)
