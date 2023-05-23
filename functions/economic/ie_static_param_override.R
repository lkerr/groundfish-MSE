# Function to update the the scalar ie_F and ie_bias values in "stock" based on ie_F_hat and iebias_hat from a previous model run
# To be more general, it would be nice to update this to take two vectors as arguments like 
#      to_update_names<-c("ie_F", "ie_bias") and
#      from_source_names<-c("ie_F_hat", "iebias_hat")
#  Although I can't think of a use case for them yet.
#  Arguments are
#     stock (the list that holds all the stock parameters and results)
#     from_model: The row from mproc that corresponds to the ie_F and ie_bias that you want to read in.  Only used when mproc$ie_source=="Internal" 

# Usage: 
# if(mproc$ImplementationClass[m]=="StandardFisheries" & mproc$ie_override[m]=="TRUE"){
#   for (i in 1:nstock){
#  if(mproc$ie_source[m]!="Internal"){  
#  
#     stock[[i]]<-ie_static_param_override(stock=stock[[i]],replicate=r, from_model=1)
#   }      
# }

ie_static_param_override <- function(stock, replicate, from_model, stocknum){
  
  stock$ie_F_OG<- stock$ie_F
  stock$ie_bias_OG<- stock$ie_bias
  
  
  
  
  # Here is the code to read in ie_F and ie_bias "externally", from an economic simulation that was run a while ago.    
  
  if(is.na(old_omvalGlobal[[stocknum]]$ie_F_hat[replicate, from_model])==TRUE){
    warning(paste0("ie_F_hat is NA in rep", replicate))
  } else {
    stock$ie_F<-old_omvalGlobal[[stocknum]]$ie_F_hat[replicate, from_model]
  }
  
  if(is.na(old_omvalGlobal[[stocknum]]$iebias_hat[replicate, from_model])==TRUE){
    warning(paste0("iebias_hat is NA in rep", replicate))
  } else{
    stock$ie_bias<-old_omvalGlobal[[stocknum]]$iebias_hat[replicate, from_model]
  }
  
  return(stock)
}