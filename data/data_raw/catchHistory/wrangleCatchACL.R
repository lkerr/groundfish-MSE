################# Georges Bank Catch History Data Wrangling ###########################
# Code Header
# Authors: Jonathan Cummings

# code Description: 
# This code reads in catch history tables from pdfs obtained from 
# https://www.greateratlantic.fisheries.noaa.gov/ro/fso/reports/Groundfish_Catch_Accounting.htm
# And wrangles the data into a common usable format.

# Last Edit: February 1, 2019

##### Load needed libraries #####
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre1.8.0_201')
library(rJava)
library(tabulizer)
library(tidyverse)
library(purrr)

# locations <- c("~/groundfish-MSE/data/data_raw/catchHistory/FY10_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY11_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY12_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY13_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY14_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY15_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY16_Mults_Catch_Estimates.pdf",
#               "~/groundfish-MSE/data/data_raw/catchHistory/FY17_Mults_Catch_Estimates.pdf")
# 
# get_pdfs<-function(locations=locations,pages=c(2:6),method="lattice"){
#   pmap(c(locations,pages,method),extract_tables)
# }

##### Functions #####
wrangle<-function(data,selVars=c(2,4,6:9,11:13,15:16),sliceVars=-c(2)){
  data<-data %>%
    select(selVars) %>% 
    slice(sliceVars)
  names(data) <- c("Stock",data[1, 2:ncol(data)])
  data<-data[-1,] %>% 
    mutate('Year'=2017)
  data
}

##### Extract and wrangle the  the tables #####
# 2010
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY10_Mults_Catch_Estimates.pdf")
FY10 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY10_Catch<-as_tibble(FY10[[1]])
FY10_Landing<-as_tibble(FY10[[2]])
FY10_Discard<-as_tibble(FY10[[3]])
FY10_TAC<-as_tibble(FY10[[4]])
FY10_CtoTAC<-as_tibble(FY10[[5]])
# Wrangle
FY10_Catch<-wrangle(FY10_Catch,selVars=c(2,4,6:9,11:12,14:15),sliceVars=-c(1,3:4))
FY10_Landing<-wrangle(FY10_Landing,selVars=c(2,4,6:9,11:12,14:15),sliceVars=-c(1,3:4))
FY10_Discard<-wrangle(FY10_Discard,selVars=c(2,4,6:9,11:12,14:15),sliceVars=-c(1,3:4))
FY10_TAC<-wrangle(FY10_TAC,selVars=c(2,4,6:9,11:12,14:15),sliceVars=-c(1,3:4))
FY10_CtoTAC<-wrangle(FY10_CtoTAC,selVars=c(2,4,6:9,11:12,14:15),sliceVars=-c(1,3:4))

# 2011
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY11_Mults_Catch_Estimates.pdf")
FY11 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY11_Catch<-as_tibble(FY11[[1]])
FY11_Landing<-as_tibble(FY11[[2]])
FY11_Discard<-as_tibble(FY11[[3]])
FY11_ACL<-as_tibble(FY11[[4]])
FY11_CtoACL<-as_tibble(FY11[[5]])
# Wrangle
FY11selVars<-c(2,4,6:9,11:12,14:15)
FY11sliceVars<- -c(1,3)
FY11_Catch<-wrangle(FY11_Catch,selVars=FY11selVars,sliceVars=FY11sliceVars)
FY11_Landing<-wrangle(FY11_Landing,selVars=FY11selVars,sliceVars=FY11sliceVars)
FY11_Discard<-wrangle(FY11_Discard,selVars=FY11selVars,sliceVars=FY11sliceVars)
FY11_ACL<-wrangle(FY11_ACL,selVars=c(1:ncol(FY11_ACL)),sliceVars=FY11sliceVars)
FY11_CtoACL<-wrangle(FY11_CtoACL,selVars=FY11selVars,sliceVars=-1)

# 2012
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY12_Mults_Catch_Estimates.pdf")
FY12 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY12_Catch<-as_tibble(FY12[[1]])
FY12_Landing<-as_tibble(FY12[[2]])
FY12_Discard<-as_tibble(FY12[[3]])
FY12_ACL<-as_tibble(FY12[[4]])
FY12_CtoACL<-as_tibble(FY12[[5]])
# Wrangle
FY12selVars<-c(2,4,6:9,11:12,14:15)
FY12sliceVars<- -c(1,3)
FY12_Catch<-wrangle(FY12_Catch,selVars=FY12selVars,sliceVars=FY12sliceVars)
FY12_Landing<-wrangle(FY12_Landing,selVars=FY12selVars,sliceVars=FY12sliceVars)
FY12_Discard<-wrangle(FY12_Discard,selVars=FY12selVars,sliceVars=FY12sliceVars)
FY12_ACL<-wrangle(FY12_ACL,selVars=FY12selVars,sliceVars=FY12sliceVars)
FY12_CtoACL<-wrangle(FY12_CtoACL,selVars=FY12selVars,sliceVars=FY12sliceVars)

#2013
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY13_Mults_Catch_Estimates.pdf")
FY13 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY13_CtoACL<-as_tibble(FY13[[1]])
FY13_ACL<-as_tibble(FY13[[2]])
FY13_Catch<-as_tibble(FY13[[3]])
FY13_Landing<-as_tibble(FY13[[4]])
FY13_Discard<-as_tibble(FY13[[5]])
# Wrangle
FY13selVars<-c(2,4,6:9,11:13,15:16)
FY13sliceVars<- -c(1,3)
FY13_CtoACL<-wrangle(FY13_CtoACL,selVars=FY13selVars,sliceVars=FY13sliceVars)
FY13_ACL<-wrangle(FY13_ACL,selVars=c(1:ncol(FY13_ACL)),sliceVars=FY13sliceVars)
FY13_Catch<-wrangle(FY13_Catch)
FY13_Landing<-wrangle(FY13_Landing)
FY13_Discard<-wrangle(FY13_Discard)

#2014
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY14_Mults_Catch_Estimates.pdf")
FY14 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY14_CtoACL<-as_tibble(FY14[[1]])
FY14_ACL<-as_tibble(FY14[[2]])
FY14_Catch<-as_tibble(FY14[[3]])
FY14_Landing<-as_tibble(FY14[[4]])
FY14_Discard<-as_tibble(FY14[[5]])
# Wrangle
FY14selVars<-c(2,4,6:9,11:13,15:16)
FY14sliceVars<- -c(1,3)
FY14_CtoACL<-wrangle(FY14_CtoACL,sliceVars=FY14sliceVars)
FY14_ACL<-wrangle(FY14_ACL,selVars=c(1:ncol(FY14_ACL)),sliceVars=FY14sliceVars)
FY14_Catch<-wrangle(FY14_Catch)
FY14_Landing<-wrangle(FY14_Landing)
FY14_Discard<-wrangle(FY14_Discard)

#2015
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY15_Mults_Catch_Estimates.pdf")
FY15 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY15_CtoACL<-as_tibble(FY15[[1]])
FY15_ACL<-as_tibble(FY15[[2]])
FY15_Catch<-as_tibble(FY15[[3]])
FY15_Landing<-as_tibble(FY15[[4]])
FY15_Discard<-as_tibble(FY15[[5]])
# Wrangle
FY15selVars<-c(2,4,6:9,11:13,15:16)
FY15sliceVars<- -c(1,3)
FY15_CtoACL<-wrangle(FY15_CtoACL,sliceVars=FY15sliceVars)
FY15_ACL<-wrangle(FY15_ACL,selVars=c(1:ncol(FY15_ACL)),sliceVars=FY15sliceVars)
FY15_Catch<-wrangle(FY15_Catch)
FY15_Landing<-wrangle(FY15_Landing)
FY15_Discard<-wrangle(FY15_Discard)

#2016
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY16_Mults_Catch_Estimates.pdf")
FY16 <- extract_tables(location,pages=c(2:6),method="lattice")
# Convert to tibbles
FY16_CtoACL<-as_tibble(FY16[[1]])
FY16_ACL<-as_tibble(FY16[[2]])
FY16_Catch<-as_tibble(FY16[[3]])
FY16_Landing<-as_tibble(FY16[[4]])
FY16_Discard<-as_tibble(FY16[[5]])
# Wrangle
FY16selVars<-c(2,4,6:9,11:13,15:16)
FY16sliceVars<- -c(1,3)
FY16_CtoACL<-wrangle(FY16_CtoACL,sliceVars=FY16sliceVars)
FY16_ACL<-wrangle(FY16_ACL,selVars=c(1:ncol(FY16_ACL)),sliceVars=FY16sliceVars)
FY16_Catch<-wrangle(FY16_Catch)
FY16_Landing<-wrangle(FY16_Landing)
FY16_Discard<-wrangle(FY16_Discard)

#2017
location<- c("~/groundfish-MSE/data/data_raw/catchHistory/FY17_Mults_Catch_Estimates.pdf")
FY17 <- extract_tables(location,pages=c(2:6),method="lattice")
#Convert to tibbles
FY17_CtoACL<-as_tibble(FY17[[1]])
FY17_ACL<-as_tibble(FY17[[2]])
FY17_Catch<-as_tibble(FY17[[3]])
FY17_Landing<-as_tibble(FY17[[4]])
FY17_Discard<-as_tibble(FY17[[5]])

FY17_CtoACL<-wrangle(FY17_CtoACL,sliceVars=-c(1,3))
FY17_ACL<-wrangle(FY17_ACL,selVars=c(1:ncol(FY17_ACL)),sliceVars=-c(1,3))
FY17_Catch<-wrangle(FY17_Catch)
FY17_Landing<-wrangle(FY17_Landing)
FY17_Discard<-wrangle(FY17_Discard)
