
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# load the necessary libraries. Same libraries are loaded
# whether using Windows or Linux but a little less complicated
# to not keep a local copy of corresponding Windows R
# packages on the machine. An Rlib directory will be
# necessary for running on the ghpcc. Note that the Rlib
# directory is located one level outside the home directory
# (i.e., it is not include in any of the github file
# transfers).

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

pkg<-c("tmvtnorm", "TMB", "abind", "glue", "tidyverse", "dplyr", "data.table","fishmethods","wham")
check.packages(pkg)

require(tmvtnorm)
require(TMB)
require(abind)
require(glue)
require(tidyverse)
require(dplyr)
require(data.table)
require(fishmethods)
require(wham)
