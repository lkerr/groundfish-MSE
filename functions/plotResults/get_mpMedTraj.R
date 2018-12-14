

# Function to plot the median trajectory over time for each MP

# mpMedMat: a matrix of medians for each trajectory where the rows are the
#           MPs and the columns are the years
#           
# x: a vector of years
# 
# ylab: y axis label
# 
# fmyidx: index for the first management year


get_mpMedTraj <- function(mpMedMat, x, ylab, fmyear=NULL){
  
  # Get y limits and extend them a little bit so that the legend does not
  # interfere
  yl <- range(mpMedMat)
  yl[2] <- 1.4 * yl[2]
  
  # number of MPs
  nmp <- nrow(mpMedMat)
  
  # Get the colors
  cols <- rainbow(nmp)
  
  matplot(x, t(mpMedMat), lty=1, pch=16, type='o', cex=1, col=cols,
          xlab = 'Year', ylab=ylab, lwd=2)
  
  legend('topright', legend=paste('MP', 1:nmp), bty='n', pch=16,
         lty=1, col=cols)
  
  abline(v=x[which(x==fmyear)], lty=3)
  
}