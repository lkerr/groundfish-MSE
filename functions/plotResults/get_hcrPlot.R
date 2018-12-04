

get_hcrPlot <- function(x){
  

  rpsum <- apply(x, 3, quantile, 
                 c(0.1, 0.5, 0.9), na.rm=TRUE)
  
  par(mar=c(4,4,1,1))
  
  plot(0, xlim=c(0, 1.5*max(rpsum[,2])), ylim=c(0, 1.5*max(rpsum[,1])), type='n',
       las=1, xlab='', ylab='')
  segments(x0 = 0,
           x1 = rpsum[,2],
           y0 = 0,
           y1 = rpsum[,1],
           lwd=3, col=c('gray30', 'black', 'gray30'))
  segments(x0 = rpsum[,2],
           x1 = 1e9,
           y0 = rpsum[,1],
           y1 = rpsum[,1],
           lwd=3, col=c('gray30', 'black', 'gray30'))
  
  mtext(side=1:2, line=c(2.5, 2.5), cex=1.25,
        c('SSB', 'F'))
  
}












