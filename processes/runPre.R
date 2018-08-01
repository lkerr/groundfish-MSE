
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
if(platform != 'Linux'){
  path_current <- Sys.getenv('PATH')
  path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                     path_current)
  Sys.setenv(PATH=path_new)
}

# load the required libraries
source('processes/loadLibs.R')

# compile the c++ file and make available to R
TMB::compile("assessment/caa.cpp")

