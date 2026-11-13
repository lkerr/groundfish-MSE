# Determine what platform the code is running on (Duplicated purposefully
# in runPre.R for running on HPCC)
platform <- Sys.info()['sysname']

# Determine whether or not this is a run on the HPCC 
# If no SLURM jobid exists, run is local. (interactive RStudio sessions on HPCC still flag as local)
# Old code using LSF_ENVDIR was specific to the resource manager on the UMass HPCC

if(platform == 'Linux'){
  runClass <- ifelse(Sys.getenv("SLURM_JOB_ID")=="", "Local", "HPCC")
}else{runClass <- 'Local'}
