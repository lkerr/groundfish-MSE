

# Function to output a data frame as a nicely formatted text file.
# 
# df: the name of the data frame object
# 
# file: the output file path


get_catdf <- function(df, file){
  
  w <- options('width')
  options(width = 9999)
  capture.output(print(mproc, row.names=FALSE, right=FALSE), file=file)
  options(w)
  
}