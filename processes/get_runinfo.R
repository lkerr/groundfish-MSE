


# Determine what platform the code is running on (Duplicated purposefully
# in runPre.R for running on HPCC)
platform <- Sys.info()['sysname']

# Determine whether or not this is a run on the HPCC by checking the name of
# the node
if(platform == 'Linux'){
  # Dig into the environmental variables
  evndir <- system('printenv LSF_ENVDIR')
  if(evndir == '/lsf/conf'){
    runClass <- 'HPCC'
  }else{
    runClass <- 'Local'
  }
}else{
  runClass <- 'Local'
}

