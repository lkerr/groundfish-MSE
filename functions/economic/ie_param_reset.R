# Function reset the scalar ie_F and ie_bias values to previously saved params.
# See ie_param_override()

# Usage: 
# for (i in 1:nstock){
#   stock[[i]]<-ie_param_reset(stock=stock[[i]])
#  }      
# 


ie_param_reset <- function(stock){

    stock$ie_F<-stock$ie_F_OG
    stock$ie_bias<-stock$ie_bias_OG
  return(stock)
}
