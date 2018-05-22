


get_plots <- function(x){
  
  
  nm <- names(x)
  
  
  
  for(i in 1:length(x)){
    
    jpeg(paste0('results/fig/', nm[i], '.jpg.'))
    
      if(all(is.na(x[[i]]))){
        plot(0)
      }else{
        get_box(x=x[[i]])
      }
    
    dev.off()
      
  }
    

  
}







