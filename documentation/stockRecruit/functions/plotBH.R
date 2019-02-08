


plotBH <- function(rep){

  newTANOM <- median(rep$TANOM)
  newSSBMT <- seq(0, max(rep$SSBMT)*1.25, length.out=100)
  Rhat = rep$a * newSSBMT / (rep$b + newSSBMT) * exp(rep$c * newTANOM)
  
  par(mar=c(4.5,4,1,1))
  
  plot(Rhat ~ newSSBMT, type = 'n', ylim=c(0, max(rep$REC000S)), ann=FALSE)
  points(rep$REC000S ~ rep$SSBMT, pch=3)
  lines(Rhat ~ newSSBMT, lwd = 3, col='firebrick1')
  
  mtext(c('SSB (MT)', 'Recruits (000s)'),
        side = 1:2,
        line = c(3, 2.5),
        cex = 1.5)
  
}



