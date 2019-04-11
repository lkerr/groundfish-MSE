# this is a small file to verify that two datasets are the same.

# Load both into memory.  rbind. and then run duplicated. If they are the same, then exactly half of the resultant vector/dataframe should be TRUE and the other half should be FALSE.  

rm(list=ls())

ffiles <- list.files(path='functions/', full.names=TRUE, recursive=TRUE)
invisible(sapply(ffiles, source))

datapath <- 'data/data_processed/econ'


savepath<-'scratch/econscratch'

load(file.path(savepath,"looped_targeting.RData"))
load(file.path(savepath,"single_targeting.RData"))


droplist<-c("exp_rev_sim","exp_rev_total_sim","harvest_sim")
th<-th[,!names(th) %in% droplist]
identical(th,th2)

keeplist<-c("id","date","spstock2","xb","totalu","prhat")
test1<-th[,names(th) %in% keeplist]
test2<-th2[,names(th2) %in% keeplist]

colnames(test2)<-c("id","date","spstock2","xb2","totalu2","prhat2")

j<-merge(test1,test2, by=c("id","date","spstock2"))
attach(j)
identical(xb, xb2)
identical(totalu, totalu2)
identical(prhat, prhat2)

