# A function to deal with the end of the day. 
# set the fishery to open if the catch is less than the ACL.  Set it to closed if it's greater than the ACL.
# dc: catch for that day of all stocks by the fleet
# fh: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
# Returns the updated version of that matrix.



get_fishery_next_period <- function(dc,fh){
  fh$cumul_catch_pounds<-dc$cumul_catch_pounds
  fh$targeted<-dc$targeted
  
  fh$sectorACL_pounds<-fh$sectorACL*pounds_per_kg*kg_per_mt
  fh$underACL<-fh$cumul_catch<fh$sectorACL_pounds
  
  num_closed<-sum(fh$underACL==FALSE)
  if (num_closed==0){
    # If nothing is closed, just return fh
  }
  else{
    
  }  
  #fh<-as.data.table(fh)
  return(fh)
}



