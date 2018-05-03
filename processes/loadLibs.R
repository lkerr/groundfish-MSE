
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. An Rlib directory will be
# necessary for running on the ghpcc.


platform <- Sys.info()['sysname']
if(platform == 'Linux'){

  # seems you need to load gmm prior to loading tmvtnorm
  require(gmm, lib.loc='Rlib/')
  require(tmvtnorm, lib.loc='Rlib/')
  require(msm, lib.loc='Rlib/')
  require(TMB, lib.loc='Rlib/')
  
}else{
  
  require(msm)
  require(tmvtnorm)
  require(TMB)
  
}

