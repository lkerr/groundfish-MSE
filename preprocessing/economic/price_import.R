# Read in pre- and post- prices and save to Rds 


mults <- read.dta13(file.path(rawpath, price_location))
mults<-as.data.table(mults)

colnames(mults)[colnames(mults)=="month"] <- "MONTH"

multipre<-mults[post==0]
multipre<-split(multipre,multipre$gffishingyear)

multipost<-mults[post==1]
multipost<-split(multipost,multipost$gffishingyear)


saveRDS(multipost, file=file.path(savepath, pricepostoutfile), compress=FALSE)

saveRDS(multipre, file=file.path(savepath, pricepreoutfile), compress=FALSE)
rm(list=c("multipre", "multipost", "mults"))


