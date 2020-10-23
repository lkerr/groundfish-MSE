get_mpMeanTrajwithEst <- function(mpMeanMat, x, nm, fmyear=NULL){
  # Get y limits and extend them a little bit so that the legend does not
  # interfere
  yl <- range(mpMeanMat)
  yl[2] <- 1.4 * yl[2]
  
  # number of MPs
  nmp <- nrow(mpMeanMat)
  
  # Get the colors
  cols <- rainbow(2)
  Est<-matrix(NA, ncol = length(files), nrow = (length(mpMeanMat)-4))
  files<-list.files()
  if (nm[i]=="SSB"){
    for (k in 1:length(files)){
      setwd(paste(tempwd,'/',files[k],sep=""))
      Est[,k]<-readRDS(paste(stockNames,"_1_",length(omval$YEAR),'.rdat',sep=""))$SSB
    }
    Est<-rowMedians(Est)
    y<-matrix(c(t(mpMeanMat[4:(length(mpMeanMat)-1)]),Est),nrow=length(Est))
  }
  if (nm[i]=="R"){
    for (k in 1:length(files)){
      setwd(paste(tempwd,'/',files[k],sep=""))
      Est[,k]<-readRDS(paste(stockNames,"_1_",length(omval$YEAR),'.rdat',sep=""))$N.age[,1]
    }
    Est<-rowMedians(Est)
    y<-matrix(c(t(mpMeanMat[5:length(mpMeanMat)]),Est),nrow=length(Est))
  }
  if (nm[i]=="F_full"){
    for (k in 1:length(files)){
      setwd(paste(tempwd,'/',files[k],sep=""))
      Est[,k]<-readRDS(paste(stockNames,"_1_",length(omval$YEAR),'.rdat',sep=""))$F.report
    }
    Est<-rowMedians(Est)
    y<-matrix(c(t(mpMeanMat[5:length(mpMeanMat)]),Est),nrow=length(Est))
  }
  x<-matrix(c(x[5:length(x)],x[5:length(x)]),nrow=length(Est))
  matplot(x, y, lty=1, pch=16, type='o', cex=1, col=cols,
          xlab = 'Year', ylab=nm[i], lwd=2)
  
  legend('topright', legend=paste(c('True','Estimated')), bty='n', pch=16,
         lty=1, col=cols)
  
  abline(v=x[which(x==fmyear)], lty=3)
  
}