


# Function to concatonate multiple simulation repetitions (i.e., from
# running on the hpcc), into a single list output for analysis. simcat
# refers to concatonating the results from the simulations.
# 
# x: list of results. What you do is combine the Rdata files from the different
#    simulation runs into a single list which is the input x.



get_simcat <- function(x){
  
  out <- list()
  for(i in 1:length(x[[1]])){
    
    z <- lapply(x, '[[', i)
    
    out[[i]] <- do.call(abind, list(z, along=1))
    
  }
  
  return(out)
  
}



