



get_SRPlot <- function(type, par, Tanom, ptyrs, stockEnv){
  
  SSBx = seq(0, max(omval$SSB, na.rm=TRUE), length.out=100)

  R <- sapply(1:length(Tanom), function(x)
         get_recruits(type=type, par=par, SSBx, TAnom_y=Tanom[x], 
                      stockEnv = stockEnv)$Rhat)
  
  pal <- colorRamp(c('cornflowerblue', 'firebrick1'))
  normTAnom <- (ptyrs-min(ptyrs)) / (max(ptyrs)-min(ptyrs))
  col <- rgb(pal(normTAnom)/255)
  
  matplot(SSBx, R, type='l', col=col, lty=1,
          xlab = 'Spawner biomass', ylab = 'Recruitment')
      
  legend('topleft', legend = c(ptyrs[1], tail(ptyrs, 1)),
         lty=1, lwd=2, col=c(col[1], tail(col, 1)), bty='n')
  
}



