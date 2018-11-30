

# Driver function to create output plots from the simulation
# 
# x: list of output for plots (i.e., omval)
# 
# dirIn: simulation directory to grab specific examples for
#        particular plots (e.g., temperature time series)




get_plots <- function(x, dirIn, dirOut){
  
  # Load one of the simulation environments
  load(file.path(dirIn, list.files(dirIn)[1]))
  
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
 
  # # Time-series temperature plot
  # jpeg(paste0(dirOut, 'tempts.jpg.'),
  #      width=480*1.75, height=480, pointsize=12*1.5)
  #   get_tempTSPlot(tempts = temp, yrs = yrs, 
  #                  fmyear=fmyear, anomStd = anomStd)
  # dev.off()
  
  
}







