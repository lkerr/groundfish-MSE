

# Driver function to create output plots from the simulation
# 
# x: list of output for plots (i.e., omval)




get_plots <- function(x, dirOut){
  
  
  nm <- names(x)
  bxidx <- which(nm %in% c("SSB", "R", "F_full", "sumCW", "sumCWcv", 
                           "ginipaaCN", "ginipaaIN"))
  
  rpidx <- which(nm == "RPs")
  
  for(i in bxidx){
    
    jpeg(paste0(dirOut, nm[i], '.jpg.'))

      # If you just have a bunch of NAs for some reason make an
      # empty plot as a place-holder
      if(all(is.na(x[[i]]))){
        plot(0)
      }else{
        get_box(x=x[[i]])
      }
    
    dev.off()
      
  }
    

  rp <- omval[[rpidx]]
  dir.create(file.path(dirOut, 'RP'), showWarnings=FALSE)
  for(i in 1:dim(rp)[2]){
  
    jpeg(paste0(dirOut, 'RP/', 'mp', i, '.jpg.'))
  
      get_rptrend(rp[,i,,])
    
    dev.off()
    
    jpeg(paste0(dirOut, 'RP/', 'hcr', i, '.jpg.'))
    
      get_hcrPlot(rp[,i,,])
    
    dev.off()
    
    
  }
  
  
}







