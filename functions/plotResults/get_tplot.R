#' @title Plot Trajectories
#' @description Generate plots of simulation trajectories
#' 
#' @param x A vector of timeseries data to plot.
#' @template global_yrs
#' @param mpName A string describing the management procedure name.
#' @param PMname A string
#' @param ylim
#' @template global_fmyear
#' 
#' @return A timeseries plot
#' 
#' @family postprocess
#' 
#' @export

get_tplot <- function(x, yrs, mpName, PMname, ylim=NULL, fmyear=NULL){
  
  plot(x ~ yrs, type='o', pch=16, xlab='', ylab='', ylim=ylim)
  mtext(side=1:3, line=c(3,3,1), cex=1.25,
        c('Year', PMname, mpName))
  
  abline(v=yrs[which(yrs==fmyear)], lty=3)
  
}
