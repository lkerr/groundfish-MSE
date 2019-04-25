

# Function to output a data frame as a nicely formatted text file.
# 
# df: the name of the data frame object
# 
# file: the output file path


get_catdf <- function(df, file){
  
  w <- options('width')
  options(width = 9999)
  capture.output(mproc, file=file)
  options(w)
  
}