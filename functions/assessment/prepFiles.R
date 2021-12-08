#' @title Maybe this doesn't need to be a function but is a chunk of code at the top of the MSE main loop (part of setup at beginning of simulations)
#' @description 
#' 
#' @param 
#' 
#' @return 
#' 
#' @family managementProcedure stockAssess
#' 
#' @export

prepFiles <- function(){
  
  # Remove compiled versions of assessment model. This is important
  # because if previous compiled versions are present they can
  # produce errors when switching from one operating system to another.
  
  fl <- list.files('assessment/')
  extlist <- strsplit(fl, split='\\.')
  ext <- sapply(extlist, tail, 1)
  fl2trash <- ext %in% c('dll', 'o', 'so')
  file.remove(file.path('assessment', fl[fl2trash]))

}

