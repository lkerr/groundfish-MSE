



# Function to return errors in an index

# type: type of error implemented
#       * "lognorm": lognormal errors
#       * ''
#       
# idx: vector of index values (e.g., survey total catch)
# 
# par: vector of parameters
#      
#      lognormal: rlnorm(1, meanlog=log(idx) - par^2/2,
#                        sdlog = par)
#                 the -par^2/2 is the bias correction


get_error_idx <- function(type, idx, par,switch){
     
if (switch==FALSE){
    idxE <- rlnorm(1, meanlog = log(idx), # - par^2/2
                      sdlog = par)
}
  
if (switch=='Pos'){

    idxE<- exp(rsnorm(1, mean = log(idx), sd = par, xi = 0.5))
}
  
if (switch=='Neg'){
    idxE<- exp(rsnorm(1, mean = log(idx), sd = par, xi = 0.5))
  }
  
  return(idxE)
  
}



