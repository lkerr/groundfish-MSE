#' @title Concatonate simulation repetitions
#' @description Concatonate multiple simulation repetitions (i.e., from running on the hpcc), into a single list output for analysis. simcat refers to concatonating the results from the simulations.
#' 
#' @param x A list of MSE results objects, where each list item was loaded from a simulation Rdata file. ??? See runPost.R for specifics
#'
#' @return ???
#' 
#' @family postprocess
#' 

get_simcat <- function(x){
  
  out <- list()
  for(i in 1:length(x[[1]])){
    
    z <- lapply(x, '[[', i)
    
    out[[i]] <- do.call(abind, list(z, along=1))
    
  }
  
  return(out)
}



