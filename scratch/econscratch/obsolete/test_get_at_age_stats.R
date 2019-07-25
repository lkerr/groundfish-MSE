
rm(list=ls())
ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))
runClass<-'local'
source('processes/loadLibs.R')



library(microbenchmark)
econsavepath <- 'scratch/econscratch'
econdatapath <- 'data/data_processed/econ'

#Setup some fake data.  Just muck around with changes and see if you can get an error message

catch_pounds<-10000
pounds_per_kg<-2.20462
catch<-catch_pounds/pounds_per_kg

selectivity <-c(.1, .25, .35, .9, .25, 1, .8, .8, 0.8) 
NAA<- c(1000, 1000, 1000, 200, 800, 200, 800,1500,2000 )
kgatage<- c(1, 2.5, 3.01, 3.89, 4.25, 5.25, 6.58, 8.58, 9.25 )


catch_kg<-catch_pounds/pounds_per_kg
kilograms_at_age<-kgatage
selC<-selectivity


outlist<-get_at_age_stats(catch_pounds/pounds_per_kg,NAA,kgatage,selectivity)


microbenchmark(get_at_age_stats(catch_pounds/pounds_per_kg,NAA,kgatage,selectivity),times=10000)

z2<-rowSums(outlist$weight_caa)*pounds_per_kg
z2
outlist

