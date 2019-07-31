# A function to deal with the end of the day. 
# set the fishery to open if the catch is less than the ACL.  Set it to closed if it's greater than the ACL.
# accumulated_catch: catch for that day of all stocks by the fleet
# fish_stats: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
# Returns the updated version of that matrix.


get_fishery_next_period <- function(accumulated_catch,fish_stats){
  fish_stats$cumul_catch_pounds<-accumulated_catch$cumul_catch_pounds
  fish_stats$targeted<-accumulated_catch$targeted
  
  fish_stats$sectorACL_pounds<-fish_stats$sectorACL*pounds_per_kg*kg_per_mt
  fish_stats$open<-fish_stats$cumul_catch<fish_stats$sectorACL_pounds
  #fish_stats<-as.data.table(fish_stats)
  return(fish_stats)
}



