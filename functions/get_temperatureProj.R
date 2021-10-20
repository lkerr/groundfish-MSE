#' @title Calculate Temperature Projection
#' @description Calculate downscaled temperature projections using the delta method. The hindcast mean is calculated over a reference period and used to calculate an anomoly for the projection period. The anomoly is then added to the mean of the observed data over that same reference period in order to downscale the projections.
#' 
#' @param prj_data A data frame with the following columns:
#' \itemize{
#'   \item{Year - Years corresponding to temperature data}
#'   \item{T - Hindcast and projected temperature timeseries. The hindcast data must encompass the period in ref_yrs}
#' } 
#' @param obs_data A data frame of observed data to scale the predicted temperature series, containing the following columns:
#' \itemize{
#'   \item{Year - Years corresponding to observed data}
#'   \item{T - Observed temperature timeseries, must overlap with period in ref_yrs}
#' }
#' @param ref_yrs A vector of length 2 containing the minimum and maximum year to define the training period used to scale temperature projections to the local data set.
#' @param plot A boolean, when TRUE plot of temperature projection generated. Default = FALSE.
#' 
#' @return A dataframe with the following: ??? Check format & contents
#' 
#' @family 
#' 

get_temperatureProj <- function(prj_data, 
                                obs_data, 
                                ref_yrs, 
                                plot=FALSE){
  
  # Pull out the reference periods
  refPrj <- subset(prj_data, 
                   YEAR >= ref_yrs[1] & YEAR <= ref_yrs[2])
  refObs <- subset(obs_data, 
                   YEAR >= ref_yrs[1] & YEAR <= ref_yrs[2])
  
  # Get the means over the reference period
  prjMean <- mean(refPrj$T)
  obsMean <- mean(refObs$T)
  
  
  # Get the downscaled mean
  # Simple mean bias correction
  # Maraun 2016 "Bias correcting climate change simulations - a 
  # critical review" Curr. Clim. Change Rep. / p.4
  dsPrj <- prj_data$T - (prjMean - obsMean)
  dsPrj <- data.frame(YEAR=prj_data$YEAR, T=dsPrj)
  rownames(dsPrj) <- NULL
  
  
  # Plot the result if called for
  
  if(plot){
    
    yrange <- range(prj_data$T, obs_data$T, dsPrj$T, na.rm=TRUE)
    xrange <- range(prj_data$YEAR)
    
    par(mar=c(4,4,4,1))
    
    plot(0, type='n', ylim=yrange, xlim=xrange, xlab='', ylab='', las=1)
    
    # reference period
    rect(xleft=ref_yrs[1], ybottom=-100, xright=ref_yrs[2], ytop=100,
         col='darkseagreen1', border='black')
    
    lines(T ~ YEAR, data=obs_data, type='o', col='black', 
          lty=3, pch=16, cex=0.5)
    lines(T ~ YEAR, data=prj_data, pch=16, cex=0.5, 
          col='slateblue', lwd=3)
    lines(T ~ YEAR, data=dsPrj, col='firebrick1', lwd=3)
    box()
    
    legend(mean(xrange), 
           yrange[2] + diff(yrange)*0.05,
           xpd=NA,
           ncol=2,
           xjust = 0.5, yjust=0,
           legend = c('Prj', 'DS Prj', 'Obs', 'ref period'),
           bty='n',
           col=c('slateblue', 'firebrick1', 'black', 'black'),
           lty=c(1,1,3,NA),
           lwd = c(3, 3, 1, NA),
           pch=c(NA, NA, 16, 22),
           pt.cex = c(1, 1, 0.75, 2.5),
           pt.bg = c(NA, NA, NA, 'darkseagreen1'))
    
    mtext(side=1:2, line=c(2.5,2.5), cex=1.25, c('Year', 'Temperature (C)'))
    
  } # End optional plot
  
  return(dsPrj)
}
