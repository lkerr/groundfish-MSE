

# Plots for simulation trajectories

get_tplot <- function(x, yrs, mpName, PMname, ylim=NULL){
  
  
  plot(x ~ yrs, type='o', pch=16, xlab='', ylab='', ylim=ylim)
  mtext(side=1:3, line=c(3,3,1), cex=1.25,
        c('Year', PMname, mpName))
  
  
}

