


plotBH <- function(rep, varyT=FALSE){

  if(!varyT){
    newTANOM <- median(rep$TANOM)
  }else{
    newTANOM <- c(-2, -1, 0, 1, 2)
  }
  newSSBMT <- seq(0, max(rep$SSBMT)*1.25, length.out=100)
  Rhat = sapply(1:length(newTANOM),
                function(x) rep$a * newSSBMT / (rep$b + newSSBMT) * 
                            exp(rep$c * newTANOM[x]))
  
  par(mar=c(4.5,4,1,1))
  
  colf <- colorRampPalette(c('blue', 'green'))
  col <- colf(length(newTANOM))
  
  matplot(newSSBMT, Rhat, type = 'n', ylim=c(0, max(rep$REC000S)), ann=FALSE)
  points(rep$REC000S ~ rep$SSBMT, pch=3)
  matlines(newSSBMT, Rhat, lwd = 3, col=col, lty=1)
  
  legend(x = 'topleft',
         legend = round(newTANOM, 2),
         lty = 1,
         lwd = 3,
         col = col,
         bty = 'n',
         title = 'Anomaly',
         cex = 0.75)
  
  mtext(c('SSB (MT)', 'Recruits (000s)'),
        side = 1:2,
        line = c(3, 2.5),
        cex = 1.5)
  
}



