# A function to deal with the end of the day loop
# accumulated_catch: catch for that day of all stocks by the fleet
# fish_stats: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
 


get_fishery_next_period <- function(accumulated_catch,fish_stats){
  
  fs<-fish_stats[c("spstock2","open","acl")]
    accumulated_catch<-merge(fs,accumulated_catch, by=c("spstock2"), all.x=TRUE)
  accumulated_catch$open<-accumulated_catch$cumul_catch<accumulated_catch$acl
  return(accumulated_catch)
}



