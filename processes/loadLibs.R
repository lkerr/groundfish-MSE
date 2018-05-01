
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. Even though there is an Rlib
# directory always it's only going to be used when running
# on the ghpcc.


platform <- Sys.info()['sysname']
if(platform == 'Linux'){

  require(msm, lib.loc='Rlib/')
  require(tmvtnorm, lib.loc='Rlib/')
  
}else{
  
  require(msm)
  require(tmvtnorm)
  
}

