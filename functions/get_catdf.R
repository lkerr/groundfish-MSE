#' @title Format catch data
#' @description Function to output a dataframe of catch data as a nicely formatted text file.
#' 
#' @param df The name of the data frame object ??? Is this a string or the dataframe, where is it used (presumably mproc?)
#' @param file: the output file path
#' 
#' @return ??? Probably want to include an explicit return() call in the function below
#' 
#' @family ???
#' 

get_catdf <- function(df, 
                      file){
  
  w <- options('width')
  options(width = 9999)
  capture.output(print(mproc, row.names=FALSE, right=FALSE), file=file)
  options(w)
  
}