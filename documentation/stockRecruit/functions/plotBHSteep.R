


plotBHSteep <- function(rep, varyT=FALSE){

  if(!varyT){
    newTANOM <- median(rep$TANOM)
  }else{
    newTANOM <- c(-2, -1, 0, 1, 2)
    # newTANOM <- c(-0.5, -0.25, 0, 0.25, 0.5)
  }
  newSSBMT <- seq(0, max(rep$SSBMT)*1.25, length.out=100)
  Rhat = sapply(1:length(newTANOM),
                function(x){
                  gamma <- -0.5 * log( (1 - 0.2) / 
                           (rep$h - 0.2) - 1) + rep$beta1* newTANOM[x]
                  hPrime <- 0.2 + (1 - 0.2) / (1 + exp(-2*gamma));
                  R0Prime <- rep$R0 * exp(rep$beta2 * newTANOM[x])
                  z <- 4 * hPrime * ( newSSBMT / (rep$SSBRF0) ) /
                    ( (1 - hPrime) + (5*hPrime - 1) * ( newSSBMT / 
                    (R0Prime * rep$SSBRF0) ) ) * exp(rep$beta3 * newTANOM[x])
                  return(z)
                })

  par(mar=c(4.5,4,1,1))
 
  colf <- colorRampPalette(c('blue', 'green'))
  col <- colf(length(newTANOM))
  
  matplot(newSSBMT, Rhat, type = 'n', ylim=c(0, max(rep$REC)), ann=FALSE)
  points(rep$REC ~ rep$SSBMT, pch=3)
  matlines(newSSBMT, Rhat, lwd = 3, col=col, lty=1)
  
  legend(x = 'topleft',
         legend = round(newTANOM, 2),
         lty = 1,
         lwd = 3,
         col = col,
         bty = 'n',
         title = 'Anomaly',
         cex = 0.75)
  
  mtext(c('SSB (MT)', 'Recruits'),
        side = 1:2,
        line = c(3, 2.5),
        cex = 1.5)
  
}



