




get_rptrend <- function(x){
  
  
  par(mfrow=c(2,1), mar=c(0,0,0,0), oma=c(5,6,1,1))
  
  boxplot(x[,,1], xaxt='n', las=1)
  mtext(side=2, line=4, cex=1.25, outer=FALSE,
        'F target')
  boxplot(x[,,2], xaxt='n', las=1)
  mtext(side=2, line=4, cex=1.25, outer=FALSE,
        'SSB target')
  ax <- 1:dim(x)[2]
  axis(1, at=ax)
  
  mtext(side=1, line=3, cex=1.5, outer=TRUE,
        'Simulation year')
  
  
}



