# A function to check whether the fleet level catch limits have been reached
#
 


get_check_fishery_open <- function(accumulated_catch,fish_stats){
  
  fs<-fish_stats[c("spstock2","open","acl")]
    accumulated_catch<-merge(fs,accumulated_catch, by=c("spstock2"), all.x=TRUE)
  accumulated_catch$open<-accumulated_catch$cumul_catch<accumulated_catch$acl
  return(accumulated_catch)
}



