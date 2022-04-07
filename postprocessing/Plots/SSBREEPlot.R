####Relative Error in SSB Plot####
#Lists numbers of scenarios that you want to compare here
Scenarios<-c(10,11,12)
#Set working directory--where the results you want to compare are stored
wd<-"C:/Users/mmazur/Desktop/COCA_Sims"
#List what is being compared
comparison<-c('Ramp','F-step','Constrained ramp')

####First Sims####
library(matrixStats)
library(dplyr)
library(ggplot2)
library(ggthemes)
setwd(paste(wd,"/Sim_",Scenarios[1],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[168:188]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[((i-168)/2),k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df<-as.data.frame(cbind(Catchsim,Year))
df$HCR<-Scenarios[1]

####Other Sims####
for (m in 2:length(comparison)){
setwd(paste(wd,"/Sim_",Scenarios[m],"/sim",sep=""))
sims <- list.files()

for (k in 1:length(sims)){
  if (file.size(sims[k])==0){
    sims[k]<-NA}
}
sims<-na.omit(sims)

Catchsim<-matrix(NA,nrow=11,ncol=length(sims))

for (k in 1:length(sims)){
  load(sims[k])
  SSBtrue<-omvalGlobal[[1]]$SSB[168:188]
  for (i in seq(170,190,2)){
    SSBest<-omvalGlobal[[1]]$SSBest[i,]
    SSBest<-na.omit(SSBest)
    SSBest<-tail(SSBest,1)
    Catchsim[((i-168)/2),k]<-((SSBest-SSBtrue[i-169])/SSBtrue[i-169])*100
  }
}

Catchsim<-rowMedians(Catchsim,na.rm=T)
Year<-seq(2019,2039,2)
df2<-as.data.frame(cbind(Catchsim,Year))
df2$HCR<-Scenarios[m]

df<-full_join(df,df2)
}

for (i in 1:length(comparison)){
  df$HCR[df$HCR==Scenarios[i]]<-comparison[i]
}
df$HCR<-as.factor(df$HCR)
df$HCR<-ordered(df$HCR,levels=comparison)

ggplot(df)+geom_line(aes(x=Year,y=Catchsim,color=HCR),size=1)+
  theme_classic()+theme(text=element_text(size=18),legend.position='bottom')+
  ylab('%REE SSB')+ ylim(min(-15,min(df$Catchsim)),max(15,max(df$Catchsim)))+
  scale_color_colorblind()+
  scale_x_continuous(limits = c(2019,2040))
