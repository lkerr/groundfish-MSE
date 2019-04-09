# this is a small file to verify that two datasets are the same.

# Load both into memory.  rbind. and then run duplicated. If they are the same, then exactly half of the resultant vector/dataframe should be TRUE and the other half should be FALSE.  

rm(list=ls())
savepath<-'scratch/econscratch'
load(file.path(savepath,"prod_good.Rdata"))

load(file.path(savepath,"prod_test.Rdata"))

ff<-rbind(temp_hold_prod, production_outputs)

tester<-duplicated(ff)

table(tester)
