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
  names(data) <- c("Stock",data[1, 2:11])
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
FY10_Catch<-wrangle(FY10_Catch,selVars=c(2,4,6:9,11:13,14:15),sliceVars=-c(1,3:4))
FY10_Landing<-wrangle(FY10_Landing,selVars=c(2,4,6:9,11:13,14:15),sliceVars=-c(1,3:4))
FY10_Discard<-wrangle(FY10_Discard,selVars=c(2,4,6:9,11:13,14:15),sliceVars=-c(1,3:4))
FY10_TAC<-wrangle(FY10_TAC,selVars=c(2,4,6:9,11:13,14:15),sliceVars=-c(1,3:4))

FY10_Landing1<-wrangle(FY10_Landing)
FY10_Discard1<-wrangle(FY10_Discard)

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
