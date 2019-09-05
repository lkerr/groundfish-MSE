# Read in post prices and save those to Rds 



mults <- read.dta13(file.path(rawpath, vsp_location))
mults<-as.data.table(mults)

multipre<-mults[post==0]
multipre<-split(multipre,multipre$gffishingyear)

multipost<-mults[post==1]

multipost<-split(multipost,multipost$gffishingyear)


saveRDS(multipost, file=file.path(savepath, vsp_postoutfile), compress=FALSE)
saveRDS(multipre, file=file.path(savepath, vsp_preoutfile),compress=FALSE)
rm(list=c("multipre", "multipost", "mults"))


