

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

    if(all(is.na(x[,i,]))){
      bp[[i]] <- NA
    }else{
      
      mn <- apply(x, c(1,2), mean, na.rm=TRUE)
      bp[[i]] <- boxplot(mn[,i], plot=FALSE)
      
    }
  }

  yrg <- range(unlist(sapply(bp, '[', 'stats')),
               unlist(sapply(bp, '[', 'out')),
               na.rm=TRUE)
  xrg <- c(0.5, length(plotIdx)+0.5)

  plot(x, type='n', ylim=yrg, xlim=xrg,
       xlab='', ylab='')
  mtext(side=1:2, line=3, cex=1.25,
        c('Management strategy', ylab))
  
  for(i in 1:length(plotIdx)){
    if(!all(is.na(x[,i,]))){
      mn <- apply(x, c(1,2), mean, na.rm=TRUE)
      boxplot(c(mn[,i]), at=i, add=TRUE)
    }
  }
  
  
  
  
}





