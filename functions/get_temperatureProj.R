

# Function to calculate downscaled temperature projections using
# delta method. The  hindcast mean is calculated  over 
# a reference period and used to calculate an anomoly for the
# projection period. The anomoly is then added to the mean of the
# observed data over that same reference period in order to downscale 
# the projections.
#
#
# prj_data: projection data - these data must include a hindcast
#           that covers the period in ref_yrs. Must be a data frame
#           with column names "Year" and "T".
#           
# obs_data: observed data to scale the predicted temperature series - 
#           these data must cover the period in ref_yrs. Must be a data 
#           frame with column names "Year" and "T".
#           
# ref_yrs: the training period to use that scales the projections
#          down to the local data set. A vector of length 2
#          (min, max).





get_temperatureProj <- function(prj_data, obs_data, 
                                ref_yrs, plot=FALSE){
  
  # Pull out the reference periods
  refPrj <- subset(prj_data, 
                   YEAR >= ref_yrs[1] & YEAR <= ref_yrs[2])
  refObs <- subset(obs_data, 
                   YEAR >= ref_yrs[1] & YEAR <= ref_yrs[2])
  
  # Get the means over the reference period
  prjMean <- mean(refPrj$T)
  obsMean <- mean(refObs$T)
  
  # Calculate the projection anomaly
  prjAnom <- prj_data$T - prjMean
  
  # Get the downscaled mean
  dsPrj <- obsMean + prjAnom
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
    
  }
  
  return(dsPrj)
  
}



