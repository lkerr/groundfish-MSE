

# Driver function to create output plots from the simulation
# 
# x: list of output for plots (i.e., omval)




get_plots <- function(x){
  
  
  nm <- names(x)
  
  
  
  for(i in 1:length(x)){
    
    jpeg(paste0('results/fig/', nm[i], '.jpg.'))
    
      # If you just have a bunch of NAs for some reason make an
      # empty plot as a place-holder
      if(all(is.na(x[[i]]))){
        plot(0)
      }else{
        get_box(x=x[[i]])
      }
    
    dev.off()
      
  }
    

  
}







