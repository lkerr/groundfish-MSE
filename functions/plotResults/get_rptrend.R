#' @title Plot Reference Point Trend
#' @description Generate box plots of reference point trends.
#' 
#' @param x A vector of F target data to plot ???
#' @param y A vector of SSB target data to plot ???
#' 
#' @return A plot of reference point trends
#' 
#' @family postprocess
#' 
#' @export

get_rptrend <- function(x, y){
  
 
  par(mfrow=c(2,1), mar=c(0,0,0,0), oma=c(5,6,1,1))
 
  boxplot(x, xaxt='n', las=1)
  mtext(side=2, line=4, cex=1.25, outer=FALSE,
        'F target')
  boxplot(y, xaxt='n', las=1)
  mtext(side=2, line=4, cex=1.25, outer=FALSE,
        'SSB target')
  ax <- 1:dim(x)[2]
  axis(1, at=ax)
  
  mtext(side=1, line=3, cex=1.5, outer=TRUE,
        'Simulation year')
  
}
