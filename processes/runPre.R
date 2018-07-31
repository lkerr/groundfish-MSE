
cat(dir('..'), file='filestest.txt')
# Code to compile TMB code before running the operating model. Doing this
# because it's probably a little better to compile once and then access the
# executable only -- certainly for when this is running on the HPCC as an
# array so you aren't trying to compile the same cpp file with multiple
# programs at once. Could include in the assessment R file, but if it's
# separate here it is easier for the HPCC to deal with.


# load the required libraries
source('processes/loadLibs.R')

# Determine whether or not this is a run on the HPCC by checking for the
# existence of the folder Rlib. Duplicate of code in runSim.R but this is
# necessary because runPre.R is run separately when run on the HPCC.
if(file.exists('Rlib')){
  runClass <- 'HPCC'
}else{
  runClass <- 'Local'
}

# Ensure that TMB will use the Rtools compiler (only windows ... and 
# not necessary on all machines)
if(platform != 'Linux'){
  path_current <- Sys.getenv('PATH')
  path_new <- paste0('c:\\Rtools\\bin;c:\\Rtools\\mingw_32\\bin;',
                     path_current)
  Sys.setenv(PATH=path_new)
}

# compile the c++ file and make available to R
TMB::compile("assessment/caa.cpp")

