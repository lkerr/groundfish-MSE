



get_SRPlot <- function(type, par, Tanom, ptyrs, stockEnv){
  
  pal <- colorRamp(c('cornflowerblue', 'firebrick1'))
  normTAnom <- (ptyrs-min(ptyrs)) / (max(ptyrs)-min(ptyrs))
  col <- rgb(pal(normTAnom)/255)
     
  # Get avg SSB across runs for each year in each
  # scenario
  pltidx <- match(ptyrs, yrs)
  avgSSB <- t(apply(omval$SSB[,,pltidx, drop=FALSE], c(2,3), mean))

  m <- matrix(c(1, rep(2, 4)))
  layout(m)
  par(mar=c(0,4,1,2))
  
  SSBx = seq(0, 1.2*max(avgSSB, par['SSBRF0'] * par['R0'], na.rm=TRUE), 
             length.out=100)
  
  R <- sapply(1:length(Tanom), function(x)
    get_recruits(type=type, par=par, SSBx, TAnom_y=Tanom[x], block = 'late',
                 stockEnv = stockEnv)$Rhat)
  
  y1 <- rev(cumsum(rep(1/ncol(avgSSB), ncol(avgSSB))))
  y0 <- y1 - 1/ncol(avgSSB)
  
  plot(NA, ylim=c(0, 1), xlim=range(SSBx), axes=FALSE,
       ann=FALSE, yaxs='i')
  
  for(i in 1:nrow(avgSSB)){
    segments(x0 = avgSSB[i,],
             y0 = y0,
             y1 = y1,
             col = col[i])
  }
  abline(h = y1[-1])
  box()
  text(x = par('usr')[1], y = (y0 + y1) / 2,
       labels = paste0('MP', 1:ncol(avgSSB)), 
       pos=2, cex = 5/ncol(avgSSB), xpd=NA)

  par(mar=c(5,4,0,2))
  matplot(SSBx, R, type='l', col=col, lty=1,
          xlab = 'Spawner biomass', ylab = 'Recruitment',
          ylim = range(0, R, par['R0']),
          xlim = range(0, par['SSBRF0'] * par['R0']))
  
  # Include reference points for R0 and SSB0 in the plot
  abline(h = par['R0'], 
         v = par['SSBRF0'] * par['R0'], 
         lty=3, col='gray50')

  
  
  legend('topleft', legend = c(ptyrs[1], tail(ptyrs, 1)),
         lty=1, lwd=2, col=c(col[1], tail(col, 1)), bty='n')
  
}



