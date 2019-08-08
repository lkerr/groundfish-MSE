# A function to deal with the end of the day. 
# set the fishery to open if the catch is less than the ACL.  Set it to closed if it's greater than the ACL.
# For the allocated multispecies stocks, set another variable (stockarea_open as a logical True/False if that stockarea is open.
# dc: catch for that day of all stocks by the fleet
# fh: data frame containing stock name, logical for open/closed, catch limit, and cumulative catch
# Returns the updated version of that matrix.



get_fishery_next_period_areaclose <- function(dc,fh){
  fh$cumul_catch_pounds<-dc$cumul_catch_pounds
  fh$targeted<-dc$targeted
  
  fh$sectorACL_pounds<-fh$sectorACL*pounds_per_kg*kg_per_mt
  fh$open<-fh$cumul_catch<fh$sectorACL_pounds
  
  #split into allocated and non-allocated
  z0<-fh[which(fh$mults_allocated==0)]
  z0$stockarea_closed<-as.logical(FALSE)
  
  fh<-fh[which(fh$mults_allocated==1)]
  
  num_closed<-sum(fh$open==FALSE)
  if (num_closed==0){
    fh$stockarea_closed<-as.logical(FALSE)
    # If nothing is closed, just return fh
  }
  else{
    
    #it's easer to check if "any" stock in an area is closed than it is to check that ALL stocks are open.
    # so we'll do that, then "flip" it over to a new open variable.
    fh<-fh[,stockarea_closed :=(sum(open==FALSE))>0, by=list(mults_allocated,stockarea)]
    
    unit_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="Unit"))
    gb_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GB"))
    gom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="GOM"))
    snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
    ccgom_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="CCGOM"))
    
    
    if (unit_check>=1){
      fh$stockarea_closed=TRUE 
    } else{
      
      if (gb_check>=1 & gom_check>=1){
        fh$stockarea_closed[which(fh$stockarea=="CCGOM")]=TRUE 
        snema_check<-length(which(fh$stockarea_closed==TRUE & fh$stockarea=="SNEMA"))
      }
    }
  }  
  
  #reassemble
  fh<-rbind(fh,z0)
  fh$stockarea_open=!fh$stockarea_closed
  fh[,stockarea_closed:=NULL]
  
  #fh<-as.data.table(fh)
  return(fh)
}
