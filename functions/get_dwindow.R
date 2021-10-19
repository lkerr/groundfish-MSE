#' @title Cut data to window of interest
#' @description  Reduce data to the window of interest (subsequently passed into the assessment model)
#'
#' @param data A list of data to be windowed ??? structure???
#' @param starty A number specifying the year to start passing data (i.e. first year in window)
#' @param endy A number specifying the year to stop passing data (i.e. last year in window)
#' 
#' @return 
#' 
#' @family ???
#' 

get_dwindow <- function(data, 
                        starty, 
                        endy){
  w <- window(data, start=starty, end=endy)
  attr(w, 'tsp') <- NULL
  
  return(w)
}


