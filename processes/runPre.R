# This code is only run on the HPCC, for local runs (runHPCC=FALSE) this is initialized in runSim

# Code to compile TMB code before running the operating model. Doing this
# because it's probably a little better to compile once and then access the
# executable only -- certainly for when this is running on the HPCC as an
# array so you aren't trying to compile the same cpp file with multiple
# programs at once. Could include in the assessment R file, but if it's
# separate here it is easier for the HPCC to deal with.


# Get the run info so the functions work appropriately whether they are
# on Windows or Linux and whether this is an HPCC run or not.
source('processes/get_runinfo.R')

# Ensure that TMB will use the Rtools compiler (only windows ... and 
# not necessary on all machines)
# If platform != Linux
if(platform == 'Windows'){
  path_current <- Sys.getenv('PATH')
  path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                     path_current)
  Sys.setenv(PATH=path_new)
} else if(platform == 'Darwin'){
  path_current <- Sys.getenv('PATH')
}



# Remove all files (as long as not running runSetup later within the plotting
# function to gather information for diagnostic plots). Ran through the 
# available environments before and after the simulation is run and found
# one variable that was only available after (active_idx) ... used that to
# determine whether or not to delete all the files in the results directory.

# Create new results directory tagged with date/time
# get and format the system time
time <- Sys.time()
timeString <- format(x = time, 
                     format = "%Y-%m-%d-%H-%M-%S")
# define a directory name
ResultDirectory <- paste('results', timeString, sep='_')
dir.create(ResultDirectory, showWarnings = FALSE, recursive=TRUE)
# Reults folders for economic models. Create them if necessary

# Generate directories for simulation results and accompanying figures
dir.create(file.path(ResultDirectory,"sim"), showWarnings = FALSE, recursive=TRUE)
dir.create(file.path(ResultDirectory,"fig"), showWarnings = FALSE, recursive=TRUE)

# Generate directories for economic results  !!! May have other econ-specific things to add here
econ_results_location<-file.path(ResultDirectory,"econ","raw")
dir.create(econ_results_location, showWarnings = FALSE, recursive=TRUE)



##### Compile the c++ file and make available to R for ASSESSCLASS == 'CAA' !!! May want this to be loaded with R package & used rather than compiling here
TMB::compile("assessment/caa.cpp")

##### Load the required libraries #####
# load the necessary libraries on the HPCC (loaded with package when run locally). # previously in sourced file loadLibs.R
# Same libraries are loaded whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. An Rlib directory will be
# necessary for running on the ghpcc. Note that the Rlib
# directory is located one level outside the home directory
# (i.e., it is not include in any of the github file
# transfers).
  
  # seems you need to load gmm prior to loading tmvtnorm
  require(gmm, lib.loc='../Rlib/')
  require(mvtnorm, lib.loc='../Rlib/')
  require(tmvtnorm, lib.loc='../Rlib/')
  
  require(expm, lib.loc='../Rlib/')
  require(msm, lib.loc='../Rlib/')
  require(Matrix, lib.loc='../Rlib/')
  require(TMB, lib.loc='../Rlib/')
  require(abind, lib.loc='../Rlib/')
  require(forcats, lib.loc='../Rlib/')
  require(readr, lib.loc='../Rlib/')
  require(tidyverse, lib.loc='../Rlib/')
  require(dplyr, lib.loc='../Rlib/')
  require(data.table, lib.loc='../Rlib/')
  require(ASAPplots, lib.loc = '../Rlib')
  require(fishmethods, lib.loc = '../Rlib')
  require(timeSeries, lib.loc = '../Rlib')
  require(fBasics, lib.loc = '../Rlib')
  require(fGarch, lib.loc = '../Rlib')
  
