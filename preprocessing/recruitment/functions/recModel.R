

## Function to build candidate recruitment model (and plot results)
## based on some temperature series. The data series that goes into
## the function is a data frame of stock and recruitment as-is in
## the time series (in other words, not adjusted for any lag in
## the number of years between spawning and recruitment).  The lag
## is a parameter in the function.
## 
## This formulation assumes that the critical time where temperature
## has an impact is during the spawning year.
## 
## data: data frame with stock biomass (MT), recruitment (N) and
##       temperature (deg C) columns.
##       
## colID: vector specifying the column IDs of (1) year (2) the stock
##        (3) the recruits and (4) the temperature. The point is to
##        make it a little easier to build a model using a different
##        temperature series (e.g., Q3 or Q4) so you can keep the
##        same data frame
##  
## rlag: lag time between spawning and observed recruitment from
##       the spawning event. If the recruits are 1-year-olds then
##       the lag would be 1 and the spawning stock from year y would
##       be related in the model to the recruits in year y+1.
##       
## plot: should plots be created
## 
## scl: vector of length 2 for plotting scale of spawner biomass
##      [1] and recruits [2]. Before plotting the values will be
##      divided by these scalars.
##      
## newT: vector giving new temperature values for plotting prediction 
##       lines. One prediction line will be plotted for each element
##       in the vector.

recModel <- function(data, colID, rlag, plot=FALSE, 
                     scl=1, newT=15){
  
  # objects indicating column IDs
  colY <- colID[1]
  colS <- colID[2]
  colR <- colID[3]
  colT <- colID[4]
  
  # set up indices for stock and recruit data (recruits are age-1 so
  # the lag time is 1 year. In the model SSB for 2000 should be lined
  # up with recruits in 2001.
  idxS <- 1:(nrow(data)-rlag)
  idxR <- (1+rlag):nrow(data)
  
  # prepare for fitting the model ... get log(R/S)
  logRS <- log(data[idxR,colR] / data[idxS,colS])
  
  ## fit the model and get coefficients and predicted values
  # log(R/S) = a + b*S + c*T
  # and on the arithmetic scale
  # R = S * exp(a + b*S + c*T)
  lm <- lm(logRS ~ data[idxS,colS] + data[idxS,colT])
  lmpar <- coef(lm)
  
  preds <- exp(lmpar[1] + lmpar[2]*data[idxS,colS] + 
               lmpar[3]*data[idxS,colT])
  Rhat <- data[idxS,colS] * preds
  
  
  ## make some plots
  if(plot){
  
    # axis labels
    axlab <- c(paste0('SSB (x', scl[1], ')'), 
               paste0('R (x', scl[2], ')'))

    ## Plot the data
    # stock-recruit data
    par(mar=c(4,4,1,1))
    plot(data[idxS,colS]/scl[1], data[idxR,colR]/scl[2], 
         pch=3, las=1, xlab='', ylab='')
    mtext(side=1:2, line=2.5, cex=1.25, axlab)
    
    # temperature data
    plot(data[,colY], data[,colT], type='o', pch=16, xlab='', 
         ylab='', las=1)
    mtext(side=1:2, line=2.5, cex=1.25, c('Year', 'SST (C)'))
    
  
    ## Model-related plots
    plot(x=data[idxR,colY], y=(data[idxR,colR]-Rhat)/scl[2], pch=3, 
         xlab='', ylab='', las=1, type='l', col='gray85')
    points(x=data[idxR,colY], y=(data[idxR,colR]-Rhat)/scl[2], pch=3)
    mtext(side=1:2, line=2.5, cex=1.25, 
          c('Year', paste('Residual x', scl[2])))
    abline(h=0, lty=3)
    
    
    # define a new range for stock size
    rS <- range(data[idxS,colS])
    newS <- seq(0, rS[2]*2, length.out=250)
    
    # make the predictions
    newR <- sapply(1:length(newT), function(x){
      newS * exp(lmpar[1] + lmpar[2]*newS + lmpar[3]*newT[x])
    })
    
    # Plot the predictions at given temperatures
    par(mar=c(4,4,3,1))
    plot(0, type='n', xlim=range(newS, data[,colS])/scl[1], 
         ylim=c(0, max(newR, data[,colR])/scl[2]),
         xlab='', ylab='', las=1)
    matplot(x=newS/scl[1], y=newR/scl[2], type='l', lwd=3, add=TRUE)
    # add the data (note that the predictions are static T)
    points(data[idxS,colS]/scl[1], data[idxR,colR]/scl[2], pch=3)
    
    mtext(side=1:2, line=c(2.5,2.5), cex=1.25,
          axlab)
    coo <- par('usr')
    medx <- mean(coo[1:2])
    nc <- length(newT)
    legend(x=medx, y=coo[4], xpd=NA, col=1:3, lty=1:3, bty='n', 
           ncol=nc, lwd=2, legend=paste0('T=', newT),
           yjust=0, cex=1.25, xjust=0.5)
  }
  
  
  return(list(par = list(data = data,
                         colID = colID,
                         rlag = rlag),
              model = lm))
  
  
  
}








