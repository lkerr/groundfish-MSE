#####Catch Trajectory Plots####
Scenarios<-c(6,32,58,116)
Stock<-'codGOM'
####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
wd<-getwd()
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[137:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2040
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

####First Assessment####
setwd(paste(wd,"/Assessment_",Scenarios[1],"/ASAP",sep=""))
tempwd <- getwd()
files<-list.files()
files<-files[4:length(files)]
Catch<-matrix(NA, ncol = length(files), nrow = 53)
for (i in 1:length(files)){
  setwd(paste(tempwd,'/',files[i],sep=""))
  Catch[,i]<-tryCatch(readRDS(paste(Stock,'_1_190.rdat',sep=""))$catch.pred,error=function(err) NA)
}

Catchest<-rowMedians(Catch,na.rm=T)
df$Catchest<-Catchest

####Second Sims####
setwd(paste(wd,"/Sim_",Scenarios[2],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[137:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2040
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[2]

####Second Assessment####
setwd(paste(wd,"/Assessment_",Scenarios[2],"/ASAP",sep=""))
tempwd <- getwd()
files<-list.files()
files<-files[4:length(files)]
Catch<-matrix(NA, ncol = length(files), nrow = 53)
for (i in 1:length(files)){
  setwd(paste(tempwd,'/',files[i],sep=""))
  Catch[,i]<-tryCatch(readRDS(paste(Stock,'_1_190.rdat',sep=""))$catch.pred,error=function(err) NA)
}

Catchest<-rowMedians(Catch,na.rm=T)
df2$Catchest<-Catchest

df<-full_join(df,df2)

####Third Sims####
setwd(paste(wd,"/Sim_",Scenarios[3],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[137:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2040
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[3]

####Third Assessment####
setwd(paste(wd,"/Assessment_",Scenarios[3],"/ASAP",sep=""))
tempwd <- getwd()
files<-list.files()
files<-files[4:length(files)]
Catch<-matrix(NA, ncol = length(files), nrow = 53)
for (i in 1:length(files)){
  setwd(paste(tempwd,'/',files[i],sep=""))
  Catch[,i]<-tryCatch(readRDS(paste(Stock,'_1_190.rdat',sep=""))$catch.pred,error=function(err) NA)
}

Catchest<-rowMedians(Catch,na.rm=T)
df2$Catchest<-Catchest

df<-full_join(df,df2)

####Fourth Sims####
setwd(paste(wd,"/Sim_",Scenarios[4],"/sim",sep=""))

sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=53,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  Catchsim[,k]<-omvalGlobal[[1]]$sumCW[137:189]
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-1988:2040
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[4]

####Fourth Assessment####
setwd(paste(wd,"/Assessment_",Scenarios[4],"/ASAP",sep=""))
tempwd <- getwd()
files<-list.files()
files<-files[4:length(files)]
Catch<-matrix(NA, ncol = length(files), nrow = 53)
for (i in 1:length(files)){
  setwd(paste(tempwd,'/',files[i],sep=""))
  Catch[,i]<-tryCatch(readRDS(paste(Stock,'_1_190.rdat',sep=""))$catch.pred,error=function(err) NA)
}

Catchest<-rowMedians(Catch,na.rm=T)
df2$Catchest<-Catchest

df<-full_join(df,df2)

df$HCR[df$HCR==Scenarios[1]]<-'Ramped'
df$HCR[df$HCR==Scenarios[2]]<-'P*'
df$HCR[df$HCR==Scenarios[3]]<-'Step in F'
df$HCR[df$HCR==Scenarios[4]]<-'Ramped with variation constraint'
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=c('Ramped','P*','Step in F','Ramped with variation constraint'))

ggplot(df)+geom_line(aes(x=Year,y=Catchest,color=HCR))+geom_point(aes(x=Year,y=Catchsim,color=HCR))+
  theme_classic()+theme(text=element_text(size=18),legend.position='right')+
  ylab('Catch (mt)')+geom_vline(xintercept=2020, linetype='dotted')+
  scale_color_manual(values=c("#EA4F12","#EACA00","#407331","#00608A"))+
  scale_y_continuous(breaks = pretty(c(0,18000), n=7),limits = c(0,18000))

