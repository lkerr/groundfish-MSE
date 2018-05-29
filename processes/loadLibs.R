
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. An Rlib directory will be
# necessary for running on the ghpcc. Note that the Rlib
# directory is located one level outside the home directory
# (i.e., it is not include in any of the github file
# transfers).


platform <- Sys.info()['sysname']
if(platform == 'Linux'){

  # seems you need to load gmm prior to loading tmvtnorm
  require(gmm, lib.loc='../Rlib/')
  require(mvtnorm, lib.loc='../Rlib/')
  require(tmvtnorm, lib.loc='../Rlib/')
  
  require(expm, lib.loc='../Rlib/')
  require(msm, lib.loc='../Rlib/')
  require(Matrix, lib.loc='../Rlib/')
  require(TMB, lib.loc='../Rlib/')
  
}else{
  
  # check.packages function: install and load multiple R packages.
  # Check to see if packages are installed. Install them if they are not, 
  # then load them into the R session.
  # https://gist.github.com/smithdanielle/9913897
  check.packages <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    if (length(new.pkg)) 
      install.packages(new.pkg, dependencies = TRUE)
    sapply(pkg, require, character.only = TRUE)
  }
  
  # Usage example
  pkg<-c("msm", "tmvtnorm", "TMB")
  check.packages(pkg)
  
  require(msm)
  require(tmvtnorm)
  require(TMB)
  
}

