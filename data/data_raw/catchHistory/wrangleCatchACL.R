test
Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jre1.8.0_201')
library(rJava)
library(tabulizer)
library(tidyverse)
library(purr)

locations <- c("~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY10_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY11_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY12_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY13_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY14_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY15_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY16_Mults_Catch_Estimates.pdf",
              "~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY17_Mults_Catch_Estimates.pdf")

get_pdfs<-function(locations=locations,pages=c(2:6),method="lattice"){
  pmap(list(locations,pages,method),extract_tables())
}

location<- c("~/groundfish-MSE/data/data_raw/estimatesCatchACL/FY17_Mults_Catch_Estimates.pdf")

# Extract the tables
#2017
FY17 <- extract_tables(location,pages=c(2:6),method="lattice")
#Convert to tibbles
FY17_CtoACL<-as_tibble(FY17[[1]])
FY17_ACL<-as_tibble(FY17[[2]])
FY17_Catch<-as_tibble(FY17[[3]])
FY17_Landing<-as_tibble(FY17[[4]])
FY17_Discard<-as_tibble(FY17[[5]])

wrangle<-function(data,selVars=c(2,4,6:9,11:13,15:16),sliceVars=-c(2)){
  data<-data %>%
    select(selVars) %>% 
    slice(sliceVars)
  names(data) <- c("Stock",data[1, 2:11])
  data<-data %>% 
    slice(-c(1)) %>% 
    mutate('Year'=2017)
  data
}

FY17_CtoACL1<-wrangle(FY17_CtoACL,sliceVars=-c(1,3))
FY17_ACL1<-wrangle(FY17_ACL,selVars=c(1:ncol(FY17_ACL)),sliceVars=-c(1,3))
FY17_Catch1<-wrangle(FY17_Catch)
FY17_Landing1<-wrangle(FY17_Landing)
FY17_Discard1<-wrangle(FY17_Discard)
