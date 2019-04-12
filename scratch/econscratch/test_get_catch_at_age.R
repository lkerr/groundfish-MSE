# some code to test the function that computes catch-at-age from the   


############################################################
#Preamble stuff that is contained in other places.
#load in functions
#set class to not HPCC
#load libraries
#declare some paths to read and save things that I'm scratchpadding
############################################################


rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))
runClass<-'local'
source('processes/loadLibs.R')
library(microbenchmark)
econsavepath <- 'scratch/econscratch'
econdatapath <- 'data/data_processed/econ'

#Setup some fake data

catch_pounds<-80000
pounds_per_kg<-2.20462
catch<-catch_pounds/pounds_per_kg

selectivity <-c(.1, .25, .35, .5, .5, 1, .8, .8, .8) 
NAA<- c(1000, 1000, 1000, 600, 500, 100, 800,1500,1500 )
kgatage<- c(1, 2.5, 3.01, 3.89, 4.25, 5.25, 6.58, 8.58, 9.25 )

mycaa<-get_catch_at_age(catch_pounds/pounds_per_kg,NAA,kgatage,selectivity)


#This may create an infinite loop if there are adjacent age classes with zero catch
#WHILE any(t)<0
t<-NAA-mycaa

#For each age class, 
#keep only the entry of t that is negative
t[t>=0]<-0
#divide by 2, shift

zz<-lag(t/2,1, default=0)+lead(t/2,1, default=0)
#allocate to the age class above and below
mycaa<-mycaa+t-zz
t<-NAA-mycaa




# catch in the 6th age class is too big



