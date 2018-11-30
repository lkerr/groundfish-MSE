



get_tempTSPlot <- function(tempts, yrs, fmyear, anomStd){
  
  anom <- temp - anomStd
  anomrg <- range(anom)
  
  par(mar=c(4,4,1,1))
  
  plot(anom ~ yrs, type='n', ann=FALSE, las=1, axes=FALSE)
  
  rect(xleft=yrs[1], 
       ybottom=anomrg[1]-(anomrg[2]-anomrg[1])*0.025, 
       xright=yrs[which(anom!=0)[1]], 
       ytop=anomrg[1]+(anomrg[2]-anomrg[1])*0.025, 
       col='lightblue', border='gray20')
  
  rect(xleft=yrs[which(anom!=0)[1]], 
       ybottom=anomrg[1]-(anomrg[2]-anomrg[1])*0.025, 
       xright=yrs[fmyear], 
       ytop=anomrg[1]+(anomrg[2]-anomrg[1])*0.025, 
       col='lightgreen', border='gray20')
  
  rect(xleft=yrs[fmyear], 
       ybottom=anomrg[1]-(anomrg[2]-anomrg[1])*0.025, 
       xright=max(yrs), 
       ytop=anomrg[1]+(anomrg[2]-anomrg[1])*0.025, 
       col='mistyrose', border='gray20')
  
  lines(anom ~ yrs, type='o', pch=16, cex=0.5, las=1, col='gray20')
  abline(h=0, lty=3)
  box()
  
  xaxlab <- pretty(yrs, 5)
  yaxlab <- pretty(anom, 5)
  axis(1, at=xaxlab, labels=TRUE, cex.axis=1.25)
  axis(2, at=yaxlab, labels=TRUE, cex.axis=1.25, las=1)
  
  mtext(side=1:2, line=c(2.5, 2.5), cex=1.25, 
        c('Year', 'Temperature Anomoly'))
  
  legend('topleft', cex=1, bty='n',
         legend=c('Burn-in Period (constant Temp)', 
                  'Burn-in Period (CMIP Temp)',
                  'Management Period (CMIP Temp)'),
         fill = c('lightblue', 'lightgreen', 'mistyrose'))

}
