#' @title ID Results Directory !!! No longer needed in setup - ResultDirectory identified in setup for runSim 
#' @description Identify which folder to store the results in. 
#' Assuming runPre() was just executed (it should have been!), identify the results folder that was most recently created.
#' ??? runPre only run locally, would not apply for HPCC, however this code is run on HPCC as well???
#' 
#' @return The name of the directory in which results will be stored (a string). 

identifyResultDirectory <- function(){
  
  resNames <- grep(pattern = 'results', # look for files containing this
                   x = list.files(),    # all files in the working directory
                   value = TRUE)        # print out the actual folder names
  
  ResultDirectory <- tail(sort(resNames), 1) # ID the most recent folder
  
  return(ResultDirectory)
}
