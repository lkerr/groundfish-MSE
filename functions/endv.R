

# Function to return the last value of a vector (just a space-saver). In some
# cases x is a matrix of 1 column, in which case it needs to first be
# converted to a vector before using the tail function.
# 
# x: the vector for which you want the last value



endv <- function(x){
  
  if(is.matrix(x)){
    
    x <- c(x)
    
  }
  
  return(tail(x, 1))
  
}





