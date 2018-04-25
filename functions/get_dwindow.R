

# Function for reducing data to the window of interest
# for feeding into the assessment model

# x: list of data to be windowed
# starty: year to start passing data
# endy: year to stop passing data

get_dwindow <- function(data, starty, endy){

  w <- window(data, start=starty, end=endy)
  attr(w, 'tsp') <- NULL
  
  return(w)
  
}


