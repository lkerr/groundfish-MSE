library(matrixStats)
library(dplyr)
library(ggplot2)
setwd("C:/Users/mmazur/Desktop/Council_Sims/Council_1/sim")
sims <- list.files()
tempwd<-getwd()
SSB<-matrix(NA,nrow=210,ncol=98)
for (i in 1:length(sims)){
  load(paste(tempwd,'/',sims[i],sep=""))
  SSB[,i]<-omvalGlobal$codGOM$SSB
}
SSB<-rowMedians(SSB)
Year<-1:210
df<-as.data.frame(cbind(SSB,Year))
df$Sim<-1

setwd("C:/Users/mmazur/Desktop/Council_Sims/Council_2/sim")
sims <- list.files()
tempwd<-getwd()
SSB<-matrix(NA,nrow=210,ncol=98)
for (i in 1:length(sims)){
  load(paste(tempwd,'/',sims[i],sep=""))
  SSB[,i]<-omvalGlobal$codGOM$SSB
}
SSB<-rowMedians(SSB)
Year<-1:210
df2<-as.data.frame(cbind(SSB,Year))
df2$Sim<-2
df<-full_join(df,df2)

df$Sim<-as.factor(df$Sim)
df<-df[df$Year>141,]
ggplot(df)+geom_line(aes(x=Year,y=SSB,colour=Sim))
