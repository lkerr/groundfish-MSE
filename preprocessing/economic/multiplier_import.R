
mults <- read.dta13(file.path(rawpath, multip_location))
mults<-as.data.table(mults)


colnames(mults)[colnames(mults)=="month"] <- "MONTH"

multipre<-mults[post==0]
multipre[, post:=NULL]

multipre<-split(multipre,multipre$gffishingyear)

multipost<-mults[post==1]
multipost[, post:=NULL]

multipost<-split(multipost,multipost$gffishingyear)


saveRDS(multipost, file=file.path(savepath, multi_postoutfile), compress=FALSE)
saveRDS(multipre, file=file.path(savepath, multi_preoutfile), compress=FALSE)


rm(list=c("multipre", "multipost", "mults"))
