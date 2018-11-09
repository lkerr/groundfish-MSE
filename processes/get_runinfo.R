


# Determine what platform the code is running on (Duplicated purposefully
# in runPre.R for running on HPCC)
platform <- Sys.info()['sysname']

# Determine whether or not this is a run on the HPCC by checking the name of
# the node
if(platform == 'Linux'){
  # Identify the name of the node
  # nn <- system('uname --nodename')
  # if(nn == 'ghpcc06'){
  #   runClass <- 'HPCC'
  # }else{
  #   runClass <- 'Local'
  # }
  runClass <- 'HPCC'
}else{
  runClass <- 'Local'
}

