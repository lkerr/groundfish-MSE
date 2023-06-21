
# Get the result directory path
source('processes/identifyResultDirectory.R')

# Get the run info so the functions work appropriately whether they are
# on Windows or Linux and whether this is an HPCC run or not.
# source('processes/get_runinfo.R')
source('processes/runSetup.R')

# Read in overall operating model parameters from the saved version
source(file.path(ResultDirectory,"set_om_parameters_global.R"))

#update mproc from the saved version

mproc <- read.csv(file.path(ResultDirectory, "fig",mprocfile), header=TRUE,
                  stringsAsFactors=FALSE)


# load all the functions
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

# load the required libraries
source('processes/loadLibs.R')

# Load in the stock-level simulation results
fl <- list.files(file.path(ResultDirectory, 'sim'), pattern="omvalGlobal", full.names=TRUE)
flLst <- list()
for(i in 1:length(fl)){
  load(fl[i])
  flLst[[i]] <- omvalGlobal
  names(flLst[[i]]) <- names(omvalGlobal)
}


boxplot_these<-c("SSB", "SSB_cur", "R", "F_full", "sumCW", "annPercentChange", 
  "meanSizeCN", "meanSizeIN", "OFdStatus", "OFgStatus" ,
  "mxGradCAA", "sumEconIW","Gini_stock_within_season_BKS")
rp_these<-c("FPROXY", "SSBPROXY")

traj_these <- c("SSB", "SSB_cur", "R", "F_full", "sumCW", 
              "ginipaaCN", "ginipaaIN", "OFdStatus",
              "mxGradCAA",
              "relE_qI", "relE_qC", "relE_selCs0", "relE_selCs1",
              "relE_ipop_mean", "relE_ipop_dev",
              "relE_R_dev", "relE_SSB", "relE_N","relE_CW", "relE_IN",
              "relE_R", "relE_F", "OFgStatus",   #AEW
              "FPROXY", "SSBPROXY","sumEconIW","Gini_stock_within_season_BKS",
              "ACL", "F_fullAdvice")

SIMboxplot_these<-c("HHI_fleet","Shannon_fleet","Gini_fleet", 
                  "Gini_fleet_bioecon_stocks", "total_rev", "total_modeled_rev", "total_groundfish_rev")
SIMrp_these<-SIMboxplot_these
SIMtraj_these <-SIMboxplot_these



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
            dirIn=file.path(ResultDirectory, "sim"), dirOut=dirOut, 
            boxnames=boxplot_these, rpnames=rp_these, trajnames=traj_these,breakyears=plotBrkYrs)
}




# Load in the aggregate simulation results
sl <- list.files(file.path(ResultDirectory, 'sim'), pattern="simlevelresults", full.names=TRUE)
#assumes there is just 1 file that matches pattern. Don't know how to stack the results together.
simlevel <-list()

if(length(sl)>=1){
  dirOut <- file.path(ResultDirectory, "fig", "simulation")
  dir.create(file.path(dirOut), showWarnings=FALSE)
  
  simlevel<-readRDS(sl)
  simlevel[['YEAR']] <- simlevel[['YEAR']][1:(length(simlevel[['YEAR']])/length(simlevel))]
  plotRP<-FALSE
  plotDrivers<-FALSE
  plotTrajInd<-TRUE
  plotTrajBox<-TRUE
  get_SimLevelplots(x=simlevel, dirIn=file.path(ResultDirectory, "sim"), dirOut=dirOut, 
                    boxnames=SIMboxplot_these, rpnames=SIMrp_these, trajnames=SIMtraj_these,breakyears=plotBrkYrs)

}





# Output the memory usage
get_memUsage(runClass = runClass)

