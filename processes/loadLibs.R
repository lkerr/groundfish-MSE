
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. An Rlib directory will be
# necessary for running on the ghpcc. Note that the Rlib
# directory is located one level outside the home directory
# (i.e., it is not include in any of the github file
# transfers).


if(runClass == 'HPCC'){

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
  require(wham, lib.loc = '.../Rlib')

}else{

  # check.packages function: install and load multiple R packages.
  # Check to see if packages are installed. Install them if they are not,
  # then load them into the R session.
  # https://gist.github.com/smithdanielle/9913897
  check.packages <- function(pkg){
    new.pkg <- pkg[!(pkg %in% installed.packages()[, "Package"])]
    
    if (length(new.pkg)){
      print(paste("********** New packages needed:", new.pkg))
      for(p in new.pkg){
        print("********* installing", p)
        if(p == "wham"){p <- "timjmiller/wham"}
        if(p == "ASAPplots"){p <- "cmlegault/ASAPplots"}
        if(p == "pak"){install.packages(p)} else{pak::pkg_install(p)}
      }
    } else{print("No new packages needed")}
    sapply(pkg, require, character.only = TRUE)
  }

  pkg <- c("pak", "gmm", "mvtnorm", "tmvtnorm", "expm", "msm", "Matrix", "TMB", "abind", "glue",
           "tidyr", "dplyr", "readr", "purrr", "tibble", "stringr", "forcats", "lubridate", "ggplot2", # core 9 tidyverse packages (tidyverse metapackage also requires ragg, which cannot be installed on HPC) 
           "data.table", "fishmethods", "timeSeries", "fBasics", "fGarch",
           "wham", "ASAPplots")
  
  check.packages(pkg)
  

  require(msm)
  require(tmvtnorm)
  require(TMB)
  require(abind)
  require(glue)
  require(tidyr)
  require(dplyr)
  require(readr)
  require(purrr)
  require(tibble)
  require(stringr)
  require(forcats)
  require(lubridate)
  require(ggplot2)
  require(data.table)
  require(ASAPplots)
  require(fishmethods)
  require(timeSeries)
  require(fBasics)
  require(fGarch)
  require(wham)

}
