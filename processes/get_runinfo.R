


# Determine what platform the code is running on (Duplicated purposefully
# in runPre.R for running on HPCC)
platform <- Sys.info()['sysname']

# Determine whether or not this is a run on the HPCC by checking for the
# existence of the folder Rlib. Duplicate of code in runSim.R but this is
# necessary because runPre.R is run separately when run on the HPCC.
if(file.exists('../../HPCC')){
  runClass <- 'HPCC'
}else{
  runClass <- 'Local'
}

