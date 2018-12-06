


# Function to generate boxplots of time series



get_tbxplot <- function(x, PMname, yrs, printOutliers, yrg){
  
  # Create some lines at what you hope is appropriate intervals
  boxplot(x, outline=printOutliers, ylim=yrg, border=NA, xaxt='n')
  axt <- axTicks(side=2)
  # hline <- c(axt, (axt-(axt[2]-axt[1])/2)[1], axt+(axt[2]-axt[1])/2)
  abline(h=axt, lty=3, col='gray70')
  
  # Generate the boxplot
  boxplot(x, xaxt='n', pch=3, cex=0.4, col='lightblue', add=TRUE,
          border='gray20', outline=printOutliers, ylim=yrg)
  
  # Get x axis labels
  xlab <- pretty(yrs, n=5)
  
  # Ensure that the axis labels will fall within the actual range
  # of years
  xlab <- xlab[xlab > min(yrs) & xlab <= max(yrs)]
  xlabidx <- match(xlab, yrs)
  
  # Print the x axis
  axis(1, at=xlabidx, labels=xlab)
  
  # Label the axes
  mtext(side=1:2, line=2.5, cex=1.25,
        c('Year', PMname))
  
}

