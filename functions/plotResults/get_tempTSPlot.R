



get_tempTSPlot <- function(temp, yrs, fmyear, ftyear){
  
  temprg <- range(temp)
  
  par(mar=c(4,4,1,1))
  
  plot(temp ~ yrs, type='n', ann=FALSE, las=1, axes=FALSE)
  
  rect(xleft=yrs[1], 
       ybottom=temprg[1]-(temprg[2]-temprg[1])*0.025, 
       xright=ftyear, 
       ytop=temprg[1]+(temprg[2]-temprg[1])*0.025, 
       col='lightblue', border='gray20')
  
  rect(xleft=ftyear, 
       ybottom=temprg[1]-(temprg[2]-temprg[1])*0.025, 
       xright=fmyear, 
       ytop=temprg[1]+(temprg[2]-temprg[1])*0.025, 
       col='lightgreen', border='gray20')
  
  rect(xleft=fmyear, 
       ybottom=temprg[1]-(temprg[2]-temprg[1])*0.025, 
       xright=max(yrs), 
       ytop=temprg[1]+(temprg[2]-temprg[1])*0.025, 
       col='mistyrose', border='gray20')
  
  lines(temp ~ yrs, type='o', pch=16, cex=0.5, las=1, col='gray20')
  abline(h=0, lty=3)
  box()
  
  xaxlab <- pretty(yrs, 5)
  yaxlab <- pretty(temp, 5)
  axis(1, at=xaxlab, labels=TRUE, cex.axis=1.25)
  axis(2, at=yaxlab, labels=TRUE, cex.axis=1.25, las=1)
  
  mtext(side=1:2, line=c(2.5, 2.5), cex=1.25, 
        c('Year', 'Temperature'))
  
  legend('topleft', cex=1, bty='n',
         legend=c('Burn-in Period (constant Temp)', 
                  'Burn-in Period (CMIP Temp)',
                  'Management Period (CMIP Temp)'),
         fill = c('lightblue', 'lightgreen', 'mistyrose'))

}
