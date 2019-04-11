# A function to deal with the end of the day. 
# set the fishery to open if the catch is less than the ACL.  Set it to closed if it's greater than the ACL.
# accumulated_catch: catch for that day of all stocks by the fleet
# fish_stats: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
# Returns the updated version of that matrix.


get_fishery_next_period <- function(accumulated_catch,fish_stats){
  
  fs<-fish_stats[c("spstock2","open","acl")]
  accumulated_catch<-left_join(fs,accumulated_catch, by=c("spstock2"), all.x=TRUE)
  accumulated_catch$open<-accumulated_catch$cumul_catch<accumulated_catch$acl
  return(accumulated_catch)
}



