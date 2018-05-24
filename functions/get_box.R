

# Function to create boxplots of simulation output
# 
# x: input data (i.e., a list element from omval)




get_box <- function(x, plotIdx=NULL, ylab='Value'){
  
  
  if(is.null(plotIdx)){
    plotIdx <- 1:dim(x)[2]
  }
  
  
  # boxplot parameter list
  bp <- list()
  for(i in 1:length(plotIdx)){
    # 1 in last dim for value rather than estimate
    if(all(is.na(x[,i,,,]))){
      bp[[i]] <- NA
    }else{
      bp[[i]] <- boxplot(x[,i,,,], plot=FALSE)
    }
  }

  yrg <- range(unlist(sapply(bp, '[', 'stats')),
               unlist(sapply(bp, '[', 'out')),
               na.rm=TRUE)

  plot(x, type='n', ylim=yrg, xlim=c(0, length(plotIdx)),
       xlab='', ylab='')
  mtext(side=1:2, line=3, cex=1.25,
        c('Management strategy', ylab))
  
  for(i in 1:length(plotIdx)){
    if(!all(is.na(x[,i,,,]))){
      boxplot(x[,i,,,], at=i, add=TRUE)
    }
  }
  
  
  
  
}





